--!strict
-- A-XZF-Tune / kısa başlangıç rehberi
-- 1. Bu ModuleScript aracın içinde kalır; ayarları buradan değiştirin.
-- 2. Play'i durdurun, bir değeri değiştirin, tekrar Play ile deneyin.
-- 3. Yeni ayar hatalıysa aracın AXZFError attribute'u sebebi gösterir.
-- Birimler: stud, saniye ve Roblox kütlesi. Power bir çarpandır; gerçek HP değildir.
-- Gövde/tekerlek yerlerini değiştirirken docs/MODEL-INTEGRATION.md'yi okuyun.
return {
	SchemaVersion = 1,
	-- MOTOR / SÜRÜŞ: gücü önce küçük adımlarla artırın.
	Power = 1, -- 0.1..5; örn. 1.2 = varsayılan motor kuvvetinin %120'si
	MaxSpeed = 180, -- stud/s; bu hızdan sonra motor itişi kesilir, yokuş hızını zorla sınırlamaz
	Drive = "RWD", -- "FWD" önden, "RWD" arkadan, "AWD" dört tekerlekten
	Mass = 0, -- 0 = Chassis'in mevcut kütlesi; >0 = Roblox kütlesi, kg değildir
	-- TEKER / SÜSPANSİYON: Radius gerçek teker yarıçapına uymalıdır.
	Radius = 1.25,
	RestLength = 1.6, -- spring top ile tam açık teker merkezi arası
	FrequencyHz = 3.5, -- sertlik; artırınca daha sert, azaltınca daha yumuşak
	DampingRatio = 0.85, -- sönümleme; aşırı değerler sürüşü sertleştirir
	Grip = 1.2, -- tutuş; 0.8 daha kaygan, 1.4 daha tutucu bir başlangıçtır
	BrakeAcceleration = 90,
	SteerDegrees = 32, -- düşük hızdaki direksiyon açısı
	-- KURTARMA: yalnızca ters dönmüş, yavaş ve zemine yakın araçta çalışır.
	AutoRecover = true,
	RecoverDelay = 2, -- saniye; boş yer yoksa bekler, diğer araçların içine taşımaz
	RecoverMaxSpeed = 6,
	-- GÖRÜNÜM / EFEKTLER
	VFX = true,
	VFXIntensity = 1, -- 0..2; client tarafındaki lastik dumanı/toz bütçesi
	SpeedScale = 1, -- gösterilen sayı = stud/s * SpeedScale; fiziksel hız değişmez
	SpeedUnit = "STUD/S", -- kendi oyun ölçeğiniz varsa etiketi ve çarpanı birlikte değiştirin
	ShowControls = true, -- H ile gizlenebilen klavye yardımının başlangıç durumu
	-- TUŞLAR: Enum.KeyCode yazmayın, aşağıdaki gibi tuşun adını string girin.
	-- Her işlem farklı bir tuş kullanmalı. Örn. Handbrake = "P" yapılabilir.
	-- Gamepad ve dokunmatik düğmeler klavye düzeninden bağımsız çalışır.
	Controls = {
		Forward = "W", Reverse = "S", Left = "A", Right = "D",
		Brake = "B", Handbrake = "Space", Exit = "E", HideControls = "H",
	},
}
