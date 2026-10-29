# A-XZF-Tune çalışma kılavuzu

Bağımsız, MIT lisanslı Roblox dört tekerlekli araç kiti. A-Chassis fork'u değildir; upstream kod, Tune tabloları veya model mekanikleri kopyalanmaz. Hedef: parçalı herhangi bir araç gövdesini açık bir rig sözleşmesiyle bağlamak, modüler fizik, güvenli ağ girdileri, kurulum denetimi ve ölçülebilir testler.

Gerçek kök bu Git deposudur. Başlangıç sırası: bu dosya, HANDOVER.md, ROADMAP.md, PROGRESSION.md son kayıtları. Dört süreklilik belgesi yalnızca MARKDOWNS/ altında tutulur. Geçmiş kayıtlar korunur; gerçek İstanbul zamanıyla yeni kayıt eklenir.

Yığın: Luau, Roblox Studio, Python 3 (bağımlılıksız paketleme), Rojo uyumlu proje. `src/Shared`: saf hesaplar/şema; `src/Server`: fizik/ağ/yaşam döngüsü; `src/Client`: sürücü girdisi; `examples/`: bağımsız araç ve pist üretimi; `tests/`: sunucu birim/entegrasyon testleri; `tools/`: paketleme; `docs/`: kullanıcı belgeleri; `evidence/`: gerçek test çıktıları.

Doğrulanmış komutlar: `python tools/build.py`; Windows'ta `python tools/check.py --compiler .tools/luau/luau-compile.exe --runtime .tools/luau/luau.exe`. Python 3.10+, Luau 0.744; kurulum/hash docs/INSTALLATION.md. 49 dosya derlenir, 68 headless sözleşme testi çalışır, paket byte eşitliği denetlenir. Studio birim girişi `require(game.ServerStorage.AXZFTests.RunUnitTest)()`; çok istemci komutu docs/TESTING.md. Rojo yolu sunuldu ama bu makinede Aftman shim yapılandırılmadığı için doğrulanmadı. Studio hedefi: A-XZF-Tune, placeId 72435697524161. Var olan ServerStorage.R3dTuxedo içeriğini değiştirme. Workspace.Baseplate/SpawnLocation korunur. Studio çalışması yerel edit/play; canlı yayınlama, satın alma ve kalıcı veri erişimi yok.

Kurallar: tek kaynak Git'teki Luau dosyaları; Studio kopyaları bu kaynaklardan kurulur. Client yalnızca sınırlı kontrol niyeti gönderir; fizik sunucuda. NaN/Inf, sıra, koltuk yetkisi, hız sınırlama ve zaman aşımı doğrulanır. Dinamik require(assetId), loadstring ve üçüncü taraf yürütülebilir kod yok. Imported art karantinada incelenir; açık yeniden dağıtım hakkı yoksa Git'e konmaz. Model kimliği/lisansı ile kit lisansı ayrıdır. Güvenilir olmayan asset kodu Play'de çalıştırılmaz.

Production-ready iddiası yalnızca doğrulanmış release kapıları kapanınca yapılır. Tek istemci testini multiplayer veya mobil test gibi raporlama. Yapılmayan kontrolleri açıkça kaydet.

0.2 kaynakları: ui/runtime onaylı native cockpit verisi/controller; vfx/runtime MIT Emit/Build ve özgün VehicleRecipes; examples/VehicleTune araç içi Türkçe rehber. Yerel dış-art sahne .rbxl ve native paketi ignore edilir; docs/ASSETS.md opsiyonel rbxmk yolunu açıklar. Kullanıcı HUD için açıkça yuvarlak sürümü onayladı; tekrar onay gerekmez. VFX için roblox-vfx kullanıldı.
