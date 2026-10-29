--!strict
-- A-XZF-Tune | ARAÇ İÇİ AYAR REHBERİ (0.3)
-- Bu ModuleScript aracın doğrudan altında, adı Tune olacak şekilde kalır.
-- BAŞLANGIÇ: Play'i durdur > tek değeri küçük adımlarla değiştir > Play > DriveSeat'e otur.
-- Yanlış değer/isim aracın AXZFError attribute'unda görünür; Output'u da kontrol edin.
-- Örnek: Power=1.2 %20 fazla motor kuvveti; MaxSpeed=120 daha düşük motor hız sınırı.
-- Örnek: Controls.Park="O" park tuşunu O yapar. Her işlem farklı tuş kullanmalı.
-- Birimler Roblox stud / saniye / kütledir; kg, metre veya gerçek beygir gücü değildir.
-- Power/TorqueScale HP değildir; oyun motor kuvvetine uygulanan çarpanlardır.
-- Geometri/mount/Wheels rehberi: docs/MODEL-INTEGRATION.md; ayrıntılar: docs/TUNING.md.
-- Desteklenen bütün alanlar aşağıda. Bilinmeyen A-Chassis alanları kabul edilmez.
return {
	SchemaVersion = 1, -- şema sürümü; değiştirmeyin

	-- 1 / MOTOR VE AKTARMA
	Drive = "RWD", -- FWD: ön / RWD: arka / AWD: dört teker çekiş
	Power = 1, -- 0.1..5; kuvvet çarpanı, 1.2 = %120
	TorqueScale = 4, -- 0.1..100; TorqueCurve kuvvet ölçeği; Power ile birlikte çarpılır
	MaxSpeed = 180, -- 5..600 stud/s; üstünde motor itişi kesilir; yokuş hızını kilitlemez
	Mass = 0, -- 0..5000; 0 mevcut Chassis kütlesi, >0 kökün hedef Roblox kütlesi
	-- Yolcu ayrıca eklenir. Kütle / Chassis hacmi yoğunluğu 0.01..100 içinde olmalı.
	IdleRPM = 850, -- 100..5000; rölanti devri
	RedlineRPM = 7000, -- 1000..20000; devir üst sınırı ve HUD ölçeği
	ShiftDownRPM = 2100, -- 100..10000; vites küçültme eşiği
	ShiftUpRPM = 6100, -- 500..20000; vites büyütme eşiği
	-- Şart: IdleRPM < ShiftDownRPM < ShiftUpRPM < RedlineRPM.
	ShiftTime = 0.3, -- 0.05..3 saniye; vites değişiminde çekişin %35'e düşme süresi
	FinalDrive = 3.7, -- 0.1..15; artırınca teker kuvveti/devir artar, vitesler kısalır
	ReverseRatio = 3.1, -- 0.1..10; geri vites oranı
	Gears = {3.2,2.1,1.5,1.12,0.88}, -- 1..10 pozitif oran; büyükten küçüğe
	TorqueCurve = {{850,95},{2500,150},{4500,175},{7000,110}}, -- {RPM,oyun torku}; 2..32 nokta
	-- RPM noktaları kesin artmalı; tork 0..100000; aralarında doğrusal geçiş.

	-- 2 / TEKER, SÜSPANSİYON VE VİRAJ DENGESİ
	-- Teker RPM = |yol hızı| / (2*pi*Radius) * 60; motor devri vites/final oranıyla farklıdır.
	-- Rölantide araç dururken tekerler durur; yalnızca görsel dönüş istemcide akıcıdır.
	Radius = 1.25, -- 0.1..10 stud; gerçek teker yarıçapına eşleştirin
	RestLength = 1.6, -- 0.1..10 stud; mount ile tam açık teker merkezi arası
	FrequencyHz = 3.5, -- 1..12; artarsa yay sertleşir ve statik çökme azalır
	DampingRatio = 0.85, -- 0.1..3; artarsa zıplama daha hızlı söner; aşırısı sertleştirir
	MaxLoad = 4, -- 1..10; teker başına statik ağırlığın azami katı
	-- RestLength > Gravity/(2*pi*FrequencyHz)^2 + 0.1 olmalı; aksi durumda bind reddedilir.
	RollInfluence = 0.2, -- 0..1; lastik kuvvetinin dikey kolu; düşürmek yatmayı azaltır
	AntiRoll = 0.5, -- 0..2; aynı aksın yayları arası denge; artarsa yatış azalır
	RollDamping = 4, -- 0..20 /s; roll hızını söndürür; havada yönü kilitlemez
	-- Eski yatış: RollInfluence=1, AntiRoll=0, RollDamping=0.
	-- Önce Radius/mount/kütle doğru olsun. Fazla Grip ve yüksek yolcu merkezi devirme riskini artırır.

	-- 3 / LASTİK, FREN VE DİREKSİYON
	Grip = 1.2, -- 0.05..3; zemin Grip attribute'u ile çarpılan lastik tutuşu
	LateralResponse = 12, -- 0.1..40 /s; yan kaymayı düzeltme; artarsa daha keskin tutar
	BrakeAcceleration = 90, -- 1..500 stud/s^2; B / mobil fren dört tekeri frenler
	HandbrakeAcceleration = 110, -- 1..500; Space yalnızca arka tekerleri frenler
	RollingResistance = 0.015, -- 0..0.2; gazsız yuvarlanma direnci
	Drag = 0.025, -- 0..2; hızın karesiyle direnç; artırmak son hızı düşürür
	SteerDegrees = 32, -- 1..60 derece; düşük hız direksiyon açısı
	SteerResponse = 7, -- 0.1..30 /s; artarsa direksiyon daha çabuk döner
	SteerFadeSpeed = 100, -- 1..500 stud/s; hızla direksiyon azaltma ölçeği
	MinSteerFraction = 0.28, -- 0.05..1; yüksek hızda kalan açı oranı

	-- 4 / PARK VE KURTARMA
	ParkOnSpawn = false, -- true: araç ilk oluştuğunda park modunda başlar
	AutoParkOnExit = false, -- true: sürücü ayrılınca otomatik park isteği
	ParkBrakeAcceleration = 140, -- 1..500; P modunda dört teker fren kuvveti
	ParkEngageSpeed = 1.5, -- 0.1..3 stud/s; Stopping -> Parked gösterge eşiği
	-- P: gaz kesilir, yavaşlayıp park eder. Tekrar P: sürüş serbest.
	-- Park isteği araçtan inince/zaman aşımında korunur. Araç Anchored olmaz; tutuş sınırı vardır.
	-- Space el freni bağımsızdır; HB durumu ayrıca görünür.
	AutoRecover = true, -- ters, yavaş, zemine yakın ve boş alan varsa düzelt
	RecoverDelay = 2, -- 0.5..15 saniye; devrik bekleme süresi
	RecoverMaxSpeed = 6, -- 0.1..15 stud/s; üstünde düzeltme bekler

	-- 5 / GÖSTERGE VE GÖRSEL EFEKTLER
	VFX = true, -- istemcide lastik dumanı / zemin tozu
	VFXIntensity = 1, -- 0..2; efekt yoğunluğu; 0 üretimi durdurur
	SpeedScale = 1, -- 0.01..10; görünen hız = stud/s * bu çarpan
	SpeedUnit = "STUD/S", -- 1..12 karakter; oyun ölçeğinize uygun etiket
	ShowControls = true, -- klavye yardımının ilk durumu; H ile gizlenebilir

	-- 6 / AĞ VE GÜNCELLEME
	InputTimeout = 0.35, -- 0.1..2 saniye; girdi kesilince gaz bırakılır ve fren uygulanır
	TelemetryHz = 10, -- 1..20 /s; HUD attribute sıklığı; fizik hızı değildir
	SleepAfter = 3, -- 0..30 saniye; boş/durgun araçta görsel işi azaltır; yay desteği sürer

	-- 7 / KLAVYE (Enum.KeyCode yerine string tuş adları)
	-- Harfler, Space, oklar, Left/RightShift, Left/RightControl, One..Five desteklenir.
	-- Her tuş benzersiz: Handbrake="P" isterseniz Park="O" gibi farklı tuş da verin.
	-- Mobil resimli düğmeler aynı işlemleri çağırır; klavye tuşlarından bağımsızdır.
	-- Gamepad: R2 gaz, L2 geri, B fren, A el freni, X park, Y çıkış, sol çubuk direksiyon.
	Controls = {
		Forward = "W", Reverse = "S", Left = "A", Right = "D",
		Brake = "B", Handbrake = "Space", Park = "P", Exit = "E", HideControls = "H",
	},
}
