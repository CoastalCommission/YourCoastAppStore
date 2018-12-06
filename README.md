# Coastal for iOS

## Getting Started

```
git clone https://github.com/metalabdesign/coastal-ios.git
cd coastal-ios
git submodule update --init --recursive
```

## Dependencies

Using [CocoaPods](https://cocoapods.org), in the root of the project, run:

```
pod install
```

Be sure to use the same version of CocoaPods that was used to generate `Podfile.lock`. One way to do that is through [podenv](https://github.com/kylef-archive/podenv).

## Publish build internally

### Install AWSCli

1. Install Python via brew (https://brew.sh)
2. Install PIP via Python (https://pip.pypa.io/en/stable/installing)
3. Install AWSCli via PIP (`pip install AWSCli`)
4. Run `aws configure` (leave `Default region name` and `Default output format`)

### Exporting from Xcode

1. Select `Beta` scheme.
1. Make sure the signing certificate is set to `iPhone Distribution: MetaLab Design Ltd.`
2. Go to `Product` → `Archive`
3. Select `Save for Enterprise Distribution`
	We don't need manifest for over-the-air installation

### Download a copy of the Coastal property list from AWS

Type `aws s3 ls s3://betalab-ios`: You should see a whole bunch of plists and ipas. The plists are the metadata used to determine whether or not to update when we check AWS for new versions.

Use `aws s3 cp s3://betalab-ios/coastal.plist .` to download a copy of the Coastal plist to your present directory (I recommend `~/Desktop`)
Open that and update the version number to whatever you exported above

### Update the AWS versions of the Coastal ipa and plist

Use these commands from whatever directory the file you're trying to upload is (again, I recommend `~/Desktop`)<br/>
`aws s3 cp path/to/file.ipa s3://betalab-ios/coastal.ipa --acl public-read`<br/>
`aws s3 cp path/to/file.plist s3://betalab-ios/coastal.plist --acl public-read`<br/>