// Supabase Edge Function: delete-account
//
// Neden gerekli: Flutter tarafındaki eski deleteAccount() sadece public.users
// tablosundaki satırı siliyordu. Bu, o kullanıcıya ait uygulama verisini
// temizliyordu (users.id -> her tabloya ON DELETE CASCADE ile bağlı) ama
// auth.users'taki gerçek kimliği (e-posta/şifre, OAuth bağlantıları) SİLMİYORDU.
// Apple/Google "hesap silme" şartı, kullanıcının login kimliğinin de silinmesini
// ister — sadece verinin temizlenmesi yeterli değil.
//
// Bu fonksiyon service_role anahtarıyla çalışır (o yüzden client'tan değil,
// sunucu tarafında, bu Edge Function içinde çağrılır). service_role anahtarı
// asla Flutter uygulamasına gömülmemeli.
//
// Deploy:
//   supabase functions deploy delete-account
//
// Not: SUPABASE_URL ve SUPABASE_SERVICE_ROLE_KEY, Supabase Edge Functions
// runtime'ında otomatik olarak ortam değişkeni olarak sağlanır, ayrıca
// tanımlamana gerek yok.

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const authHeader = req.headers.get('Authorization');
    if (!authHeader) {
      return new Response(JSON.stringify({ error: 'Yetkilendirme başlığı eksik' }), {
        status: 401,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    // Bu client, çağıranın KENDİ oturum token'ıyla oluşturuluyor.
    // Amacı sadece "bu isteği gerçekten kim yapıyor" sorusunu güvenli
    // şekilde cevaplamak (auth.getUser() token'ı Supabase'e doğrulatır).
    const supabaseUserClient = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_ANON_KEY')!,
      { global: { headers: { Authorization: authHeader } } },
    );

    const { data: { user }, error: userError } = await supabaseUserClient.auth.getUser();
    if (userError || !user) {
      return new Response(JSON.stringify({ error: 'Geçersiz veya süresi dolmuş oturum' }), {
        status: 401,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    // Admin client — service_role anahtarı SADECE burada, sunucu tarafında
    // kullanılıyor. Flutter uygulaması bu anahtarı hiçbir zaman görmez.
    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    );

    // public.users satırını sil. users.id -> auth.users(id) ON DELETE CASCADE
    // olduğu için asıl auth kullanıcısını silmek zaten bunu otomatik yapar,
    // ama burada açıkça da siliyoruz (iki adım da güvenlik/telafi amaçlı).
    const { error: dbError } = await supabaseAdmin.from('users').delete().eq('id', user.id);
    if (dbError) {
      console.error('users tablosu silme hatası:', dbError.message);
      // Kritik olan asıl kimlik silme adımı, o yüzden burada durmuyoruz.
    }

    // Asıl kimliği (e-posta/şifre, OAuth bağlantıları, oturumlar) sil.
    // Bu olmadan kullanıcı "silinen" hesabıyla giriş yapmaya devam edebilir.
    const { error: authError } = await supabaseAdmin.auth.admin.deleteUser(user.id);
    if (authError) {
      console.error('auth kullanıcı silme hatası:', authError.message);
      return new Response(
        JSON.stringify({ error: 'Hesap silinemedi: ' + authError.message }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
      );
    }

    return new Response(JSON.stringify({ success: true }), {
      status: 200,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  } catch (e) {
    console.error('delete-account beklenmeyen hata:', e);
    return new Response(JSON.stringify({ error: String(e) }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }
});
