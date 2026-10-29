# A-XZF-Tune

Sıfırdan yazılmış, modüler Roblox araç kiti. A-Chassis fork'u veya Tune tablosunun yeniden adlandırılması değildir. **0.2.0 release candidate:** çalışan uygulama ve gerçek Studio testleri mevcut; v1.0 öncesi kalan değerlendirme kapıları [READINESS.md](docs/READINESS.md) içinde.

## Hızlı başlangıç

1. [Demo sahnesini](build/A-XZF-Tune-Demo.rbxlx) Roblox Studio'da aç, Play'e bas.
2. Turuncu prototipin sürücü koltuğuna otur.
3. W/S ileri-geri, A/D direksiyon, B fren, Space aç/kapat el freni, E çıkış, H tuş yardımını gizle/göster. Telefonda ayrı dokunma düğmeleri vardır. Gamepad: RT/LT, sol analog, B fren, A el freni, Y çıkış.

[Kurulum](docs/INSTALLATION.md), [kendi modelini bağlama](docs/MODEL-INTEGRATION.md), [ayarlar](docs/TUNING.md), [API](docs/API.md), [A-Chassis'ten geçiş](docs/MIGRATION.md), [testler](docs/TESTING.md).

Gövde panelleri ve tekerlekleri ayrı modellerle çalışır. Model denetçisi kurulum hatalarını çalıştırmadan bildirir; bağlantılar sökülünce eski parça özellikleri geri yüklenir. Fizik sunucuda, sürücü komutları yetki/biçim/sıra/hız sınırından geçirilir. Süspansiyon, lastik tutuşu, yüzeye bağlı Grip, otomatik vites, Ackermann ve hızla azalan direksiyon ayrı modüllerdedir.

75 Studio birim testi, 68 harici Luau sözleşme testi, iki araçla sürüş testleri ve iki istemcili ağ testi geçti. Ayrıntılı ölçümler ve eksik testler raporlarda ayrıdır. Dış kaynaklı gerçek parçalı araç yerel Studio'da test edildi; sanat varlıkları MIT lisanslıymış gibi GitHub'a eklenmedi. [Kaynak ve yeniden kurma](docs/ASSETS.md).

Tüm geliştirme dosyaları bu Git deposunun içindedir. `MARKDOWNS/` proje sürekliliği belgelerini içerir; kullanıcı belgeleri `docs/` altındadır.

## 0.2 yenilikleri

Yuvarlak hız/devir göstergesi, gizlenebilir ve Tune'dan değiştirilebilir tuşlar, ayrı mobil gaz/fren/el freni/çıkış, boş alan denetimli otomatik düzeltme, kararlı örtük süspansiyon, lastik dumanı/toz ve araç içi açıklamalı Tune eklendi. Üç gerçek A-Chassis araçta dönüşüm, sürüş ve titreşim testleri geçti. [Uyumluluk sonuçları](docs/COMPATIBILITY.md), [tek çağrıyla dönüşüm](docs/MIGRATION.md), [arayüz](docs/HUD.md), [efektler](docs/VFX.md).
