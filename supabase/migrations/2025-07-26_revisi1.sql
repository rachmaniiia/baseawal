

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;


CREATE SCHEMA IF NOT EXISTS "public";


ALTER SCHEMA "public" OWNER TO "pg_database_owner";


COMMENT ON SCHEMA "public" IS 'standard public schema';



CREATE TYPE "public"."jenis_item_enum" AS ENUM (
    'produk',
    'jasa'
);


ALTER TYPE "public"."jenis_item_enum" OWNER TO "postgres";


CREATE TYPE "public"."kategori_produk_enum" AS ENUM (
    'sayuran',
    'sarana_pertanian'
);


ALTER TYPE "public"."kategori_produk_enum" OWNER TO "postgres";


CREATE TYPE "public"."metode_pembayaran_enum" AS ENUM (
    'VA',
    'COD'
);


ALTER TYPE "public"."metode_pembayaran_enum" OWNER TO "postgres";


CREATE TYPE "public"."metode_pengiriman_enum" AS ENUM (
    'kurir_ndaru',
    'pihak_ketiga'
);


ALTER TYPE "public"."metode_pengiriman_enum" OWNER TO "postgres";


CREATE TYPE "public"."role_admin_enum" AS ENUM (
    'admin',
    'operator'
);


ALTER TYPE "public"."role_admin_enum" OWNER TO "postgres";


CREATE TYPE "public"."status_pembayaran_enum" AS ENUM (
    'belum_bayar',
    'menunggu_konfirmasi',
    'berhasil',
    'gagal'
);


ALTER TYPE "public"."status_pembayaran_enum" OWNER TO "postgres";


CREATE TYPE "public"."status_pengiriman_enum" AS ENUM (
    'belum_dikirim',
    'siap_dikirim',
    'dalam_perjalanan',
    'sampai',
    'gagal_dikirim'
);


ALTER TYPE "public"."status_pengiriman_enum" OWNER TO "postgres";


CREATE TYPE "public"."status_pesanan_enum" AS ENUM (
    'pending',
    'diproses',
    'dikirim',
    'selesai',
    'dibatalkan'
);


ALTER TYPE "public"."status_pesanan_enum" OWNER TO "postgres";


CREATE TYPE "public"."tipe_pengiriman_enum" AS ENUM (
    'langsung',
    'preorder'
);


ALTER TYPE "public"."tipe_pengiriman_enum" OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."insert_history_pembayaran"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public'
    AS $$
BEGIN
  IF NEW.status_pembayaran IS DISTINCT FROM OLD.status_pembayaran THEN
    INSERT INTO history_pembayaran (id_pembayaran, status_pembayaran, catatan, created_by)
    VALUES (NEW.id_pembayaran, NEW.status, 'Perubahan status otomatis', NULL);
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."insert_history_pembayaran"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."insert_history_pesanan"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public'
    AS $$
BEGIN
  IF NEW.status_pesanan IS DISTINCT FROM OLD.status_pesanan THEN
    INSERT INTO history_pesanan (id_pesanan, status_pesanan, catatan, created_by)
    VALUES (NEW.id_pesanan, NEW.status_pesanan, 'Perubahan status otomatis', NULL);
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."insert_history_pesanan"() OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "public"."alamat_pengguna" (
    "id_alamat" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "id_pengguna" "uuid",
    "label" "text",
    "alamat_lengkap" "text",
    "kecamatan" "text",
    "kota" "text",
    "provinsi" "text",
    "kode_pos" "text",
    "telepon_penerima" "text",
    "latitude" numeric,
    "longitude" numeric,
    "created_at" timestamp without time zone DEFAULT "now"(),
    "updated_at" timestamp without time zone DEFAULT "now"(),
    "deleted_at" timestamp without time zone
);


ALTER TABLE "public"."alamat_pengguna" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."berita" (
    "id_berita" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "judul" "text" NOT NULL,
    "konten" "text" NOT NULL,
    "url_gambar" "text",
    "dibuat_oleh" "uuid",
    "created_at" timestamp without time zone DEFAULT "now"(),
    "updated_at" timestamp without time zone DEFAULT "now"(),
    "deleted_at" timestamp without time zone
);


ALTER TABLE "public"."berita" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."detail_pesanan" (
    "id_detail" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "id_pesanan" "uuid",
    "jenis_item" "public"."jenis_item_enum",
    "id_produk" "uuid",
    "id_jasa" "uuid",
    "kuantitas" integer,
    "harga_satuan" integer,
    "subtotal" integer,
    "created_at" timestamp without time zone DEFAULT "now"(),
    "updated_at" timestamp without time zone DEFAULT "now"(),
    "deleted_at" timestamp without time zone
);


ALTER TABLE "public"."detail_pesanan" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."jasa" (
    "id_jasa" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "nama_jasa" "text" NOT NULL,
    "deskripsi" "text",
    "harga" integer NOT NULL,
    "jadwal" "text",
    "url_gambar" "text",
    "dibuat_oleh" "uuid",
    "created_at" timestamp without time zone DEFAULT "now"(),
    "updated_at" timestamp without time zone DEFAULT "now"(),
    "deleted_at" timestamp without time zone
);


ALTER TABLE "public"."jasa" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."keranjang" (
    "id_keranjang" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "id_user" "uuid",
    "id_produk" "uuid",
    "id_jasa" "uuid",
    "jenis_item" "public"."jenis_item_enum",
    "kuantitas" integer NOT NULL,
    "catatan" "text",
    "created_at" timestamp without time zone DEFAULT "now"(),
    "updated_at" timestamp without time zone DEFAULT "now"(),
    "deleted_at" timestamp without time zone
);


ALTER TABLE "public"."keranjang" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."kurir" (
    "id_kurir" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "nama" "text" NOT NULL,
    "is_internal" boolean DEFAULT false,
    "created_at" timestamp without time zone DEFAULT "now"(),
    "updated_at" timestamp without time zone DEFAULT "now"()
);


ALTER TABLE "public"."kurir" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."log_activity_admin" (
    "log_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "admin_id" "uuid" NOT NULL,
    "aksi" "text" NOT NULL,
    "ip_address" character varying,
    "user_agent" "text",
    "created_at" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE "public"."log_activity_admin" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."lokasi_toko" (
    "id_toko" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "alamat" "text",
    "latitude" numeric,
    "longitude" numeric,
    "created_at" timestamp without time zone DEFAULT "now"(),
    "updated_at" timestamp without time zone DEFAULT "now"()
);


ALTER TABLE "public"."lokasi_toko" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."notifikasi" (
    "id_notifikasi" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "id_pengguna" "uuid",
    "pesan" "text",
    "terbaca" boolean DEFAULT false,
    "created_at" timestamp without time zone DEFAULT "now"()
);


ALTER TABLE "public"."notifikasi" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."pembayaran" (
    "id_pembayaran" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "id_pesanan" "uuid",
    "nomor_va" "text",
    "bank" "text",
    "status" "public"."status_pembayaran_enum",
    "waktu_pembayaran" timestamp without time zone,
    "created_at" timestamp without time zone DEFAULT "now"(),
    "updated_at" timestamp without time zone DEFAULT "now"(),
    "deleted_at" timestamp without time zone
);


ALTER TABLE "public"."pembayaran" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."pengiriman" (
    "id_pengiriman" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "id_pesanan" "uuid",
    "id_kurir" "uuid",
    "status_pengiriman" "public"."status_pengiriman_enum",
    "nama_kurir" "text",
    "nomor_kontak_kurir" "text",
    "tanggal_pengiriman" timestamp without time zone,
    "catatan" "text",
    "created_at" timestamp without time zone DEFAULT "now"(),
    "updated_at" timestamp without time zone DEFAULT "now"()
);


ALTER TABLE "public"."pengiriman" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."pesanan" (
    "id_pesanan" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "id_user" "uuid",
    "id_alamat" "uuid",
    "metode_pengiriman" "public"."metode_pengiriman_enum",
    "metode_pembayaran" "public"."metode_pembayaran_enum",
    "status_pesanan" "public"."status_pesanan_enum" DEFAULT 'pending'::"public"."status_pesanan_enum",
    "total_harga" integer,
    "ongkir" integer,
    "created_at" timestamp without time zone DEFAULT "now"(),
    "updated_at" timestamp without time zone DEFAULT "now"(),
    "deleted_at" timestamp without time zone,
    "tipe_pengiriman" "public"."tipe_pengiriman_enum" DEFAULT 'langsung'::"public"."tipe_pengiriman_enum"
);


ALTER TABLE "public"."pesanan" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."produk" (
    "id_produk" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "nama_produk" "text" NOT NULL,
    "kategori_produk" "public"."kategori_produk_enum",
    "deskripsi" "text",
    "harga" integer NOT NULL,
    "stok" integer NOT NULL,
    "berat" integer,
    "url_gambar" "text",
    "dibuat_oleh" "uuid",
    "created_at" timestamp without time zone DEFAULT "now"(),
    "updated_at" timestamp without time zone DEFAULT "now"(),
    "deleted_at" timestamp without time zone
);


ALTER TABLE "public"."produk" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."profil_admin" (
    "id_admin" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "nama" "text" NOT NULL,
    "role" "public"."role_admin_enum" NOT NULL,
    "jabatan" "text",
    "foto" "text",
    "created_at" timestamp without time zone DEFAULT "now"(),
    "updated_at" timestamp without time zone DEFAULT "now"(),
    "deleted_at" timestamp without time zone
);


ALTER TABLE "public"."profil_admin" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."profil_pengguna" (
    "id_pengguna" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "nama" "text" NOT NULL,
    "alamat" "text",
    "nomor_hp" "text",
    "foto" "text",
    "created_at" timestamp without time zone DEFAULT "now"(),
    "updated_at" timestamp without time zone DEFAULT "now"(),
    "deleted_at" timestamp without time zone
);


ALTER TABLE "public"."profil_pengguna" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."tagihan" (
    "id_tagihan" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "id_pesanan" "uuid",
    "nomor_tagihan" "text",
    "total_tagihan" numeric,
    "status" "public"."status_pembayaran_enum",
    "tanggal_cetak" timestamp without time zone,
    "url_file" "text",
    "created_at" timestamp without time zone DEFAULT "now"(),
    "updated_at" timestamp without time zone DEFAULT "now"(),
    "deleted_at" timestamp without time zone
);


ALTER TABLE "public"."tagihan" OWNER TO "postgres";


ALTER TABLE ONLY "public"."alamat_pengguna"
    ADD CONSTRAINT "alamat_pengguna_pkey" PRIMARY KEY ("id_alamat");



ALTER TABLE ONLY "public"."berita"
    ADD CONSTRAINT "berita_pkey" PRIMARY KEY ("id_berita");



ALTER TABLE ONLY "public"."detail_pesanan"
    ADD CONSTRAINT "detail_pesanan_pkey" PRIMARY KEY ("id_detail");



ALTER TABLE ONLY "public"."tagihan"
    ADD CONSTRAINT "invoice_nomor_invoice_key" UNIQUE ("nomor_tagihan");



ALTER TABLE ONLY "public"."jasa"
    ADD CONSTRAINT "jasa_pkey" PRIMARY KEY ("id_jasa");



ALTER TABLE ONLY "public"."keranjang"
    ADD CONSTRAINT "keranjang_pkey" PRIMARY KEY ("id_keranjang");



ALTER TABLE ONLY "public"."kurir"
    ADD CONSTRAINT "kurir_pkey" PRIMARY KEY ("id_kurir");



ALTER TABLE ONLY "public"."log_activity_admin"
    ADD CONSTRAINT "log_activity_admin_pkey" PRIMARY KEY ("log_id");



ALTER TABLE ONLY "public"."lokasi_toko"
    ADD CONSTRAINT "lokasi_toko_pkey" PRIMARY KEY ("id_toko");



ALTER TABLE ONLY "public"."notifikasi"
    ADD CONSTRAINT "notifikasi_pkey" PRIMARY KEY ("id_notifikasi");



ALTER TABLE ONLY "public"."pembayaran"
    ADD CONSTRAINT "pembayaran_pkey" PRIMARY KEY ("id_pembayaran");



ALTER TABLE ONLY "public"."pengiriman"
    ADD CONSTRAINT "pengiriman_pkey" PRIMARY KEY ("id_pengiriman");



ALTER TABLE ONLY "public"."pesanan"
    ADD CONSTRAINT "pesanan_pkey" PRIMARY KEY ("id_pesanan");



ALTER TABLE ONLY "public"."produk"
    ADD CONSTRAINT "produk_pkey" PRIMARY KEY ("id_produk");



ALTER TABLE ONLY "public"."profil_admin"
    ADD CONSTRAINT "profile_admin_pkey" PRIMARY KEY ("id_admin");



ALTER TABLE ONLY "public"."profil_pengguna"
    ADD CONSTRAINT "profile_user_pkey" PRIMARY KEY ("id_pengguna");



ALTER TABLE ONLY "public"."tagihan"
    ADD CONSTRAINT "tagihan_pkey" PRIMARY KEY ("id_tagihan");



CREATE OR REPLACE TRIGGER "trigger_history_pembayaran" AFTER UPDATE ON "public"."pembayaran" FOR EACH ROW EXECUTE FUNCTION "public"."insert_history_pembayaran"();



CREATE OR REPLACE TRIGGER "trigger_history_pesanan" AFTER UPDATE ON "public"."pesanan" FOR EACH ROW EXECUTE FUNCTION "public"."insert_history_pesanan"();



ALTER TABLE ONLY "public"."alamat_pengguna"
    ADD CONSTRAINT "alamat_pengguna_id_pengguna_fkey" FOREIGN KEY ("id_pengguna") REFERENCES "public"."profil_pengguna"("id_pengguna");



ALTER TABLE ONLY "public"."berita"
    ADD CONSTRAINT "berita_created_by_fkey" FOREIGN KEY ("dibuat_oleh") REFERENCES "public"."profil_admin"("id_admin");



ALTER TABLE ONLY "public"."detail_pesanan"
    ADD CONSTRAINT "detail_pesanan_id_jasa_fkey" FOREIGN KEY ("id_jasa") REFERENCES "public"."jasa"("id_jasa");



ALTER TABLE ONLY "public"."detail_pesanan"
    ADD CONSTRAINT "detail_pesanan_id_pesanan_fkey" FOREIGN KEY ("id_pesanan") REFERENCES "public"."pesanan"("id_pesanan");



ALTER TABLE ONLY "public"."detail_pesanan"
    ADD CONSTRAINT "detail_pesanan_id_produk_fkey" FOREIGN KEY ("id_produk") REFERENCES "public"."produk"("id_produk");



ALTER TABLE ONLY "public"."profil_admin"
    ADD CONSTRAINT "fk_admin_auth" FOREIGN KEY ("id_admin") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "public"."profil_pengguna"
    ADD CONSTRAINT "fk_user_auth" FOREIGN KEY ("id_pengguna") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "public"."jasa"
    ADD CONSTRAINT "jasa_created_by_fkey" FOREIGN KEY ("dibuat_oleh") REFERENCES "public"."profil_admin"("id_admin");



ALTER TABLE ONLY "public"."keranjang"
    ADD CONSTRAINT "keranjang_id_jasa_fkey" FOREIGN KEY ("id_jasa") REFERENCES "public"."jasa"("id_jasa");



ALTER TABLE ONLY "public"."keranjang"
    ADD CONSTRAINT "keranjang_id_pengguna_fkey" FOREIGN KEY ("id_user") REFERENCES "public"."profil_pengguna"("id_pengguna");



ALTER TABLE ONLY "public"."keranjang"
    ADD CONSTRAINT "keranjang_id_produk_fkey" FOREIGN KEY ("id_produk") REFERENCES "public"."produk"("id_produk");



ALTER TABLE ONLY "public"."log_activity_admin"
    ADD CONSTRAINT "log_activity_admin_admin_id_fkey" FOREIGN KEY ("admin_id") REFERENCES "public"."profil_admin"("id_admin");



ALTER TABLE ONLY "public"."notifikasi"
    ADD CONSTRAINT "notifikasi_id_pengguna_fkey" FOREIGN KEY ("id_pengguna") REFERENCES "public"."profil_pengguna"("id_pengguna");



ALTER TABLE ONLY "public"."pembayaran"
    ADD CONSTRAINT "pembayaran_id_pesanan_fkey" FOREIGN KEY ("id_pesanan") REFERENCES "public"."pesanan"("id_pesanan");



ALTER TABLE ONLY "public"."pengiriman"
    ADD CONSTRAINT "pengiriman_id_kurir_fkey" FOREIGN KEY ("id_kurir") REFERENCES "public"."kurir"("id_kurir");



ALTER TABLE ONLY "public"."pengiriman"
    ADD CONSTRAINT "pengiriman_id_pesanan_fkey" FOREIGN KEY ("id_pesanan") REFERENCES "public"."pesanan"("id_pesanan");



ALTER TABLE ONLY "public"."pesanan"
    ADD CONSTRAINT "pesanan_id_alamat_pengguna_fkey" FOREIGN KEY ("id_alamat") REFERENCES "public"."alamat_pengguna"("id_alamat");



ALTER TABLE ONLY "public"."pesanan"
    ADD CONSTRAINT "pesanan_id_pengguna_fkey" FOREIGN KEY ("id_user") REFERENCES "public"."profil_pengguna"("id_pengguna");



ALTER TABLE ONLY "public"."produk"
    ADD CONSTRAINT "produk_created_by_fkey" FOREIGN KEY ("dibuat_oleh") REFERENCES "public"."profil_admin"("id_admin");



ALTER TABLE ONLY "public"."tagihan"
    ADD CONSTRAINT "tagihan_id_pesanan_fkey" FOREIGN KEY ("id_pesanan") REFERENCES "public"."pesanan"("id_pesanan");



GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";



GRANT ALL ON FUNCTION "public"."insert_history_pembayaran"() TO "anon";
GRANT ALL ON FUNCTION "public"."insert_history_pembayaran"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."insert_history_pembayaran"() TO "service_role";



GRANT ALL ON FUNCTION "public"."insert_history_pesanan"() TO "anon";
GRANT ALL ON FUNCTION "public"."insert_history_pesanan"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."insert_history_pesanan"() TO "service_role";



GRANT ALL ON TABLE "public"."alamat_pengguna" TO "anon";
GRANT ALL ON TABLE "public"."alamat_pengguna" TO "authenticated";
GRANT ALL ON TABLE "public"."alamat_pengguna" TO "service_role";



GRANT ALL ON TABLE "public"."berita" TO "anon";
GRANT ALL ON TABLE "public"."berita" TO "authenticated";
GRANT ALL ON TABLE "public"."berita" TO "service_role";



GRANT ALL ON TABLE "public"."detail_pesanan" TO "anon";
GRANT ALL ON TABLE "public"."detail_pesanan" TO "authenticated";
GRANT ALL ON TABLE "public"."detail_pesanan" TO "service_role";



GRANT ALL ON TABLE "public"."jasa" TO "anon";
GRANT ALL ON TABLE "public"."jasa" TO "authenticated";
GRANT ALL ON TABLE "public"."jasa" TO "service_role";



GRANT ALL ON TABLE "public"."keranjang" TO "anon";
GRANT ALL ON TABLE "public"."keranjang" TO "authenticated";
GRANT ALL ON TABLE "public"."keranjang" TO "service_role";



GRANT ALL ON TABLE "public"."kurir" TO "anon";
GRANT ALL ON TABLE "public"."kurir" TO "authenticated";
GRANT ALL ON TABLE "public"."kurir" TO "service_role";



GRANT ALL ON TABLE "public"."log_activity_admin" TO "anon";
GRANT ALL ON TABLE "public"."log_activity_admin" TO "authenticated";
GRANT ALL ON TABLE "public"."log_activity_admin" TO "service_role";



GRANT ALL ON TABLE "public"."lokasi_toko" TO "anon";
GRANT ALL ON TABLE "public"."lokasi_toko" TO "authenticated";
GRANT ALL ON TABLE "public"."lokasi_toko" TO "service_role";



GRANT ALL ON TABLE "public"."notifikasi" TO "anon";
GRANT ALL ON TABLE "public"."notifikasi" TO "authenticated";
GRANT ALL ON TABLE "public"."notifikasi" TO "service_role";



GRANT ALL ON TABLE "public"."pembayaran" TO "anon";
GRANT ALL ON TABLE "public"."pembayaran" TO "authenticated";
GRANT ALL ON TABLE "public"."pembayaran" TO "service_role";



GRANT ALL ON TABLE "public"."pengiriman" TO "anon";
GRANT ALL ON TABLE "public"."pengiriman" TO "authenticated";
GRANT ALL ON TABLE "public"."pengiriman" TO "service_role";



GRANT ALL ON TABLE "public"."pesanan" TO "anon";
GRANT ALL ON TABLE "public"."pesanan" TO "authenticated";
GRANT ALL ON TABLE "public"."pesanan" TO "service_role";



GRANT ALL ON TABLE "public"."produk" TO "anon";
GRANT ALL ON TABLE "public"."produk" TO "authenticated";
GRANT ALL ON TABLE "public"."produk" TO "service_role";



GRANT ALL ON TABLE "public"."profil_admin" TO "anon";
GRANT ALL ON TABLE "public"."profil_admin" TO "authenticated";
GRANT ALL ON TABLE "public"."profil_admin" TO "service_role";



GRANT ALL ON TABLE "public"."profil_pengguna" TO "anon";
GRANT ALL ON TABLE "public"."profil_pengguna" TO "authenticated";
GRANT ALL ON TABLE "public"."profil_pengguna" TO "service_role";



GRANT ALL ON TABLE "public"."tagihan" TO "anon";
GRANT ALL ON TABLE "public"."tagihan" TO "authenticated";
GRANT ALL ON TABLE "public"."tagihan" TO "service_role";



ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "service_role";






RESET ALL;
