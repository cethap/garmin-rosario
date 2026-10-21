# Releasing Rosario to the Connect IQ Store

A store release is a signed `.iq` package that you upload to your Garmin developer account. Sign it with your persistent developer key: every later update must be signed with that same key, or the store rejects it.

## Quick path

1. Create your persistent developer key, once ([step 1](#1-create-the-persistent-developer-key-once)).
2. Go through the [pre-submit checklist](#2-pre-submit-checklist).
3. [Export the `.iq` package](#3-export-the-iq-package).
4. [Upload it](#4-upload-to-the-connect-iq-store) on the Garmin Developer site.

Each command below was checked against the Connect IQ SDK 9.2.0 docs (`doc/docs/Core_Topics/Security.html`, `doc/docs/Monkey_C/Compiler_Options.html`, `doc/docs/Core_Topics/Publishing_to_the_Store.html`) and `monkeyc --help`.

## 1. Create the persistent developer key (once)

The compiler needs an RSA 4096-bit private key in DER format. Create it outside the repository:

```sh
mkdir -p ~/garmin-keys && cd ~/garmin-keys
openssl genrsa -out developer_key.pem 4096
openssl pkcs8 -topk8 -inform PEM -outform DER -in developer_key.pem -out developer_key.der -nocrypt
chmod 600 developer_key.pem developer_key.der
```

`developer_key.der` is the file you pass to `monkeyc -y`. `developer_key.pem` is the same key in another format.

### Keep it and back it up

| Rule | Why |
|------|-----|
| Sign every store upload with this one key | The SDK: "You will need to use the same key to sign updates to an existing app on the store. If you lose your original signing key you will not be able to update your app." |
| Never let it change | The SDK: "Your upload will be rejected If the developer key has changed since your last upload." |
| Back it up in two places, such as a password manager and an encrypted drive | Losing the key ends updates to the app |
| Keep it secret | `-nocrypt` writes the key unencrypted: whoever has the file can sign as you |
| Keep it out of the repository | `.gitignore` ignores `*.der`, `*.pem` and `developer_key*`, but store the key elsewhere anyway |
| Never release with a test key | A key made for tests or a scratch build would become the key for every update |

## 2. Pre-submit checklist

Run the commands with your persistent key in `DEVELOPER_KEY`:

```sh
export DEVELOPER_KEY=~/garmin-keys/developer_key.der
```

- [ ] **The checks and the tests pass.** With the simulator running (`connectiq &`), `scripts/test-all.sh` exits with 0 after printing:
  - `Translations OK`: every language has every text, and the generated files are up to date (`scripts/gen-i18n.py --check`);
  - `Glance texts OK`: the glance uses only what it can load (`scripts/check-glance-strings.py`);
  - `Tests PASSED`: one test build, which covers English, Spanish and French.
- [ ] **The release build has 0 warnings.** `monkeyc -f monkey.jungle -d instinct2 -o bin/Rosario.prg -y "$DEVELOPER_KEY" -r -w` prints no `WARNING` and `BUILD SUCCESSFUL`. A missing translation does not show up here, because the texts are JSON data: the translations check above catches it.
- [ ] **Version.** `manifest.xml` has no app version attribute (the SDK's manifest page lists `id`, `type`, `name`, `entry`, `launcherIcon` and `minApiLevel`), so there is nothing to bump in the repository. If the upload form asks for a version, give each update a higher one than the last, and tag the released commit with it (`git tag v1.0.0`).
- [ ] **Store texts.** Review [store/listing-eng.md](../store/listing-eng.md), [store/listing-spa.md](../store/listing-spa.md) and [store/listing-fre.md](../store/listing-fre.md). The SDK docs give no length limits for the store's fields, so check what the form accepts when you paste them.
- [ ] **Screenshots in each language.** For English, Spanish and French: the glance, the main screen during a decade, the menu, the language picker and the reading view. Choose the language with **Language** in the app's menu, then use the simulator's Save Screenshot command.
- [ ] **Rights to the Spanish quotes.** Their source page says "Copyright © Libreria Editrice Vaticana" (see [NOTICE](../NOTICE)). Garmin's App Review Guidelines (section 3a, in the SDK's `doc/docs/App_Review_Guidelines/Overview.html`) say: "You must own or have a license to use all IP included in or used by your app." Settle this before you submit.
- [ ] **Supported part numbers.** The export leaves out one Instinct 2 part number (see [step 3](#3-export-the-iq-package)). Accept it or change `minApiLevel` first.
- [ ] **The key is your persistent one**, and it is backed up.

## 3. Export the `.iq` package

```sh
monkeyc -e -f monkey.jungle -o bin/Rosario.iq -y "$DEVELOPER_KEY" -r -w
```

| Option | Meaning |
|--------|---------|
| `-e` | Package the app: an IQ file for uploading to the app store |
| `-f monkey.jungle` | The project's jungle file |
| `-o bin/Rosario.iq` | The package to write; `bin/` and `*.iq` are git-ignored |
| `-y` | The developer key that signs the package |
| `-r` | Release build, without debug information |
| `-w` | Show compiler warnings |

There is no `-d`: the package holds a build for each product in `manifest.xml`. The command writes only the `.iq` file; its intermediate files go to a temporary folder.

Expected output:

```text
WARNING: Device name: 'Instinct® 2 / Solar / Dual Power / dēzl Edition' Part number: '006-B4071-00' CIQ ver: '3.2.7' is being ignored by the package tool because it does not support the minimum API Level set for this project
0 OUT OF 1 DEVICES BUILT
1 OUT OF 1 DEVICES BUILT
BUILD SUCCESSFUL
```

The warning comes from the package tool, not the compiler. The SDK lists two part numbers for the Instinct 2:

| Part number | Connect IQ | Languages the SDK lists | In the package |
|-------------|------------|-------------------------|----------------|
| 006-B3888-00 | 3.4.2 | 28, including English, Spanish and French | Yes |
| 006-B4071-00 | 3.2.7 | English, Indonesian, Malay, Chinese (Simplified and Traditional), Japanese, Korean, Thai, Vietnamese | No: below `minApiLevel` 3.4.0 |

The left-out part number would show only English. Covering it would mean lowering `minApiLevel` and checking every API the app uses against Connect IQ 3.2. Any other warning, from the compiler, must be fixed before you submit.

To check the package (it is a 7-Zip archive):

```sh
bsdtar -tvf bin/Rosario.iq                 # manifest.xml, manifest.sig2, dev_key.pub, 006-B3888-00/Rosario.prg, debug.xml
bsdtar -xOf bin/Rosario.iq manifest.xml    # languages eng, fre, spa; no permissions
```

A test export of this version was about 28 KB.

## 4. Upload to the Connect IQ Store

The SDK's publishing page describes these steps:

1. Open the [Submit an App](http://developer.garmin.com/connect-iq/submit-an-app/) page of the Garmin Developer site and click **Submit an App** to fill out the form.
2. Upload `bin/Rosario.iq` to your developer account.
3. Once the IQ file is validated, add the description, screenshots and other details, from `store/`.
4. Wait for review. The SDK says reviews usually finish within 72 hours. While it is pending, the app does not show in the store, but you can preview and download it yourself.
5. If the app is rejected, the Connect IQ team emails the reasons. Fix them and submit again.

For an update, export with the same key, keep the app id in `manifest.xml` (`88956777-ab95-491a-a90a-85aedd95a9c1`) unchanged, and go through the checklist again.
