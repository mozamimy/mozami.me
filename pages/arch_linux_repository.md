# arch.mozami.me

きまぐれに Arch Linux のパッケージをビルドして公開しています。[guzuta](https://github.com/eagletmt/guzuta) を便利に使わせてもらっています。

[https://github.com/mozamimy/arch.mozami.me](https://github.com/mozamimy/arch.mozami.me)

## pacman から使う

[わたしの GPG public key](/gpg.html) を信頼してインポートしてください。

```
# pacman-key --recv-keys 75F773945E0FD8A0
# pacman-key --lsign-key 75F773945E0FD8A0 
```

`/etc/pacman.conf` に以下のように記述してください。

```
[aur-mozamimy]
SigLevel = Required
Server = https://arch.mozami.me/$repo/os/$arch
```
