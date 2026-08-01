> ✅ Bu fonksiyon Supabase Dashboard üzerinden (Edge Functions → Via Editor)
> zaten deploy edildi ve canlı: `https://swhldeonfravztafsfof.supabase.co/functions/v1/delete-account`.
> Aşağıdaki CLI adımları artık sadece ileride kod değişikliği yapıp yeniden
> deploy etmek istersen referans olarak duruyor.

# delete-account Edge Function — Deploy Rehberi

Bu fonksiyon gerçek hesap silmeyi yapıyor (auth.users kimliğini siliyor, sadece
public.users satırını değil). Kod hazır, tek eksik senin makinende bunu
Supabase projene deploy etmen. Aşağıdaki adımlar tek seferlik kurulum.

## 1. Supabase CLI kur

```bash
npm install -g supabase
```

(macOS'te alternatif: `brew install supabase/tap/supabase`)

## 2. Giriş yap ve projeye bağlan

```bash
cd devkom_app
supabase login
supabase link --project-ref <PROJECT_REF>
```

`<PROJECT_REF>`'i Supabase Dashboard → Project Settings → General →
Reference ID'den alabilirsin.

## 3. Fonksiyonu deploy et

```bash
supabase functions deploy delete-account
```

Bu komut JWT doğrulamasını varsayılan olarak açık bırakır (`verify_jwt: true`) —
yani fonksiyonu sadece geçerli bir oturum token'ıyla çağırmak mümkün, bu tam
istediğimiz şey (kullanıcı sadece kendi hesabını silebilir).

## 4. Ortam değişkenlerini kontrol et

`SUPABASE_URL` ve `SUPABASE_SERVICE_ROLE_KEY`, Supabase Edge Functions
runtime'ında proje bazında otomatik sağlanır — ayrıca elle eklemene gerek yok.
`SUPABASE_ANON_KEY` de öyle.

## 5. Test et

Uygulamadan bir test hesabıyla "Hesabı Sil" akışını dene. Sonrasında:
- Supabase Dashboard → Authentication → Users listesinde o kullanıcı
  görünmemeli (sadece devre dışı değil, tamamen yok olmalı).
- Aynı e-posta ile tekrar kayıt olmayı dene — "zaten kayıtlı" hatası
  ALMAMALISIN, çünkü kimlik gerçekten silindi.

## Neden bunu ben deploy edemedim

Deploy için senin Supabase hesabına `supabase login` ile giriş yapmak (tarayıcı
üzerinden OAuth) ve proje referansını bağlamak gerekiyor — bu kimlik bilgileri
bana ait olmayan bir işlem, o yüzden bu adımı senin yapman gerekiyor. Kod
tarafı (fonksiyonun kendisi + Flutter tarafındaki çağrı) tamamen hazır.
