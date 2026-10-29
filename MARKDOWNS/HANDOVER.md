# Güncel devir

Son güncelleme: 2026-10-29T21:07:36+03:00. Okuma sırası: MARKDOWNS/AGENTS.md → HANDOVER.md → ROADMAP.md → PROGRESSION.md son kayıtlar.

Kök: C:/Users/yagiz/Desktop/Projects/Life IS Roblox/A-XZF-Tune. Dal main; origin https://github.com/yagizxzf/A-XZF-Tune. Bütün geliştirme burada. Önceki GUI hotfix50b3fc0220cf0db5e3cdf58342e4017c822d9955 / Validate40908822445 success. Mevcut0.3 değişiklikleri test edildi, push/CI henüz bu kayıtta tamamlandı sayılmıyor.

## Mevcut çalışan durum

0.3.0-rc.1: P ayrı latched park, gaz kesme/dört teker fren ve düşük hızda yokuş tutuşu; Space arka el freni. Park talebi input timeout/çıkışta korunur. ParkOnSpawn ve AutoParkOnExit opsiyoneldir. P/W/P/E ve gerçek insanla opsiyonlar ana Studio'da geçti. Native seat HUD kapalı, yuvarlak cockpit P/PARK ON ve HB ON'u ayrı gösterir.

src/Shared/Parking + Stability; Server/Vehicle + Fleet; Client/Driver güncellendi. RollInfluence0.2/AntiRoll0.5/RollDamping4 varsayılanları, tutuşu kullanırken gövde yatışını azaltır. Kuvvetler persistent VectorForce/Torque; sunucu yetkisi, recovery, VFX ve implicit süspansiyon korunur.

examples/VehicleTune.luau artık49 alanın tamamını Türkçe açıklıyor: motor eğrisi/vites/RPM/güç/hız/kütle, yay/denge/lastik/direksiyon/fren, park/kurtarma, HUD/VFX/ağ ve9 tuş. Gerçek main Workspace.AXZF_Prototype.Tune ve AXZF_ImportedCar.Tune içine kuruldu. Import Radius1.5/FWD/TorqueScale5 korundu. Dört uyumluluk source modelinin Tune'ları da güncel. TuneEditor.install Edit-only helper mevcut Tune için açık overrides ister; legacy Tune çalıştırmaz. Schema1, Park=P yeni: eski Handbrake=P remap'i için Park=O gibi benzersiz tuş gerekir.

UI: ui/build.py HTML kaynak; ui/runtime generated Data ve Cockpit; kullanıcı9 simgeli mobil sürümü açıkça onayladı. Lucide tek paket, tam ISC/Feather MIT bildirimi licenses/Lucide-LICENSE.txt/NOTICE.md; provenance ui/icon-pack/provenance.json; upload ledger ui/assets.json. circle_parking action circle-pause ikonudur. Yeniden upload yapma. Opsiyonel node ui/render_icons.mjs için .tools/svg @resvg/resvg-js; normal paketleme bağımlılıksızdır. ui/REVIEW.md tasarım kararlarını korur.

## Doğrulama

56 Luau compile,83 headless, deterministik paket, Python compile, JS syntax/HTML overflow kontrolü geçti. Lab/ana Studio/açık yerel demoda90/90 unit geçti. evidence/v3-*.json ve ui/shots/v3-studio-*.png; ayrıntı docs/TESTING.md#03-validation.

RollTest: aynı24 Roblox kütleli yolcu temsili,55/90 stud/s başlangıç veiki yön. Import tepe8.409→0.457°, prototype10.329→0.879°; yaw/upright eşikleri geçti. Dört dış model jitter: RMS açısal0.00260/0.03209/0.04892/0.00310rad/s, yükseklik aralığı0. Havada itiş0/yüzey tutuşu/geri/el freni/service-brake eğim regresyonu geçti.

Park: anaP/W park hız0.0034, P bırakınca48.36stud/s; E sonrasıpark korundu. Son8° statik park0.0589stud/s <0.1. OnSpawn/AutoParkOnExit insanla geçti. İlk opsiyon testinde yanlış seating setup başarısızdı; retest sonucu ayrı korunur. İlk roll bound-clone testi hata verdi; fresh-factory baseline ayrı korunur. Eski başarısız çıktılar başarı diye işaretlenmez.

Mobil: iPhone7(666×374 GUI),13(749×388),iPadA16(1179×819), landscape.9 ikon yüklenir; tekGUI; min84.5×58.5px, overlap yok. Gaz1→0 dışarı bırakma, fren,iki yön,geri,ayrıHB/P,help/exit/nativeTouch restorasyonu ve yeniden giriştepark geçti. MainHUDgearP/HB ayrı. Bu place LandscapeSensor:0.3 portre/fiziksel multitouch/gamepad ve yeni0.3 çok-client park/ağ testi yapılmadı. Önceki0.2 iki-client yetki testleri tarihsel kanıttır.

## Studio ve teslim

Asıl hedef A-XZF-Tune place72435697524161 / built-in ID22a56821-c454-406f-86dd-4ea0c00752d6 güncel0.3 kaynak/UI/Tune ile Edit bırakıldı. Kullanıcı penceresi kapatılmadı. R3dTuxedo/baseplate/spawn ve geometriler korundu, canlı publish yok.

Lab built-in4b297fbf-84ef-47c1-9ab1-c06845d9c69a / community instance:i5h-8xn; delivery built-ine7f88962-485a-4a3b-aefa-159f877bd2f3 / community instance:9jh-9ve. İkisi Edit; cihaz simülasyonu default. Community MCP köprüsü persistent node_repl rpc/mt/installCode/tuneUpgradeCode değişkenleriyle açık. Ana eski kullanıcı penceresinde community yüklenmediği için yalnızca bu ana hedefe mevcut built-in bağlantıyla SES kaynak installer uygulanır. Ana pencereyi kapatma.

Public build/A-XZF-Tune.rbxmx ve A-XZF-Tune-Demo.rbxlx güncel. Yerel gerçek araçlı build/A-XZF-CompatibilityDemo.rbxl yeniden üretildi; açık demo da aynı kaynaklar/Tune'larla güncellendi ve5 araç/90 test geçti. Bu oturumda binary dosya yeniden ayrı pencerede açılmadı. Native source build/AXZF-CompatibilityCars.rbxm güncellendi; iki dosya da Git dışında. Üçüncü taraf artı MIT gibi dağıtma.

Komutlar: python tools/build.py; python tools/check.py --compiler .tools/luau/luau-compile.exe --runtime .tools/luau/luau.exe; opsiyonel python tools/export_compatibility.py (.tools/rbxmk/rbxmk.exe0.9.1 ve uyumluAPI descriptor). Native decoder serialized size aliaslarını korur; güncel PhysicalProperties bozulmasını önlemek için yerel sourceTune.Mass=1.2*rootvolume yazılır, rootphysics yeniden kurulurken uygulanır. Ayrıntı docs/ASSETS.md.

Studio kurulumunda ScriptEditorService.UpdateSourceAsync kullan; açık buffer/Source eşitlenmesi bir frame gecikebilir, Edit okumalarında GetEditorSource kullan. Mevcut StarterPlayerScripts gibi özel container'ları yeniden parent etme. Kaynak Git'tedir; Studio'da ayrı kopya uydurma.

## Sıradaki somut adımlar

0.3 kaynak/belge değişikliklerini gözden geçirip GitHub main'e normal commit/push; Validate CI sonucunu oku. Ardından PROGRESSION'a gerçek commit/CI ekle, ROADMAP teslimini tamamlandı yap ve bu HANDOVER'ın pending durumunu düzelt. Stabil1.0 henüz ilan edilmez: fiziksel input, kötü ağ/streaming, uzun soak/toplam engine/network/GPU/memory profil ve Roblox-aware typing/modernA-Chassis1.7.2 model kontrolleri açık. Otomatik yayın/satın alma/DataStore yok.
