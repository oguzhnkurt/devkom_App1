# RLS Policy Fix - Uygulama Talimatları

## Neler Yapıldı?

1. ✅ Tüm admin ekranları silindi
2. ✅ Admin özelliklerine ait kodlar temizlendi
3. ✅ RLS policy'lerini düzelten SQL migration oluşturuldu

## Şimdi Yapmanız Gerekenler

Supabase'de RLS policy'lerini düzeltmek için bu SQL kodunu çalıştırmanız gerekiyor.

### Adım 1: Supabase Dashboard'a Git

1. https://supabase.com adresine git
2. Projenizi aç (devkom-dfdca)
3. Sol menüden **SQL Editor**'ü aç

### Adım 2: SQL Kodunu Kopyala ve Çalıştır

1. Aşağıdaki dosyayı aç:
   ```
   C:\Users\Oguzhan\devkom_app\supabase\migrations\04_remove_admin_features.sql
   ```

2. Tüm içeriği kopyala

3. Supabase SQL Editor'e yapıştır

4. Sağ üstteki **RUN** butonuna bas

### Adım 3: Sonucu Kontrol Et

SQL çalıştıktan sonra:
- Yeşil "Success" mesajı görmelisiniz
- Eğer hata alırsanız, hatayı bana gönderin

## Özet

Bu SQL migration şunları yapacak:
- ❌ Infinite recursion yaratan `auth.is_admin()`, `auth.is_teacher()`, `auth.is_parent()` fonksiyonlarını silecek
- ❌ Admin permission'larına dayalı tüm RLS policy'lerini silecek
- ✅ "Users can insert own profile" policy'sini düzeltecek (public olacak)
- ✅ Basitleştirilmiş yeni policy'ler ekleyecek (admin check'leri olmadan)

Bu değişikliklerden sonra:
- ✅ Kayıt işlemi çalışacak
- ✅ Infinite recursion hatası olmayacak
- ✅ Veriler Supabase'e kayıt edilecek
- ❌ Admin özellikleri olmayacak (zaten kaldırıldı)
- ❌ Teacher/Parent özel özellikleri olmayacak

## SQL'i Çalıştırdıktan Sonra

SQL'i başarıyla çalıştırdıktan sonra:
1. Uygulamayı yeniden başlat
2. Kayıt ol ekranından yeni bir kullanıcı oluşturmayı dene
3. Artık "infinite recursion" hatası almamalısın
4. Kullanıcı verileri Supabase users tablosuna kayıt edilmeli

Herhangi bir sorun yaşarsan bana haber ver!
