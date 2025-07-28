

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



CREATE TYPE "public"."admin_role_enum" AS ENUM (
    'admin',
    'operator'
);


ALTER TYPE "public"."admin_role_enum" OWNER TO "postgres";


CREATE TYPE "public"."delivery_status_enum" AS ENUM (
    'not_sent',
    'ready_to_send',
    'in_transit',
    'delivered',
    'delivery_failed'
);


ALTER TYPE "public"."delivery_status_enum" OWNER TO "postgres";


CREATE TYPE "public"."item_type_enum" AS ENUM (
    'product',
    'service'
);


ALTER TYPE "public"."item_type_enum" OWNER TO "postgres";


CREATE TYPE "public"."order_status_enum" AS ENUM (
    'pending',
    'processing',
    'shipped',
    'completed',
    'cancelled'
);


ALTER TYPE "public"."order_status_enum" OWNER TO "postgres";


CREATE TYPE "public"."payment_method_enum" AS ENUM (
    'VA',
    'COD'
);


ALTER TYPE "public"."payment_method_enum" OWNER TO "postgres";


CREATE TYPE "public"."payment_status_enum" AS ENUM (
    'unpaid',
    'pending_confirmation',
    'successful',
    'failed'
);


ALTER TYPE "public"."payment_status_enum" OWNER TO "postgres";


CREATE TYPE "public"."product_category_enum" AS ENUM (
    'vegetables',
    'agriculture_supplies'
);


ALTER TYPE "public"."product_category_enum" OWNER TO "postgres";


CREATE TYPE "public"."shipping_method_enum" AS ENUM (
    'ndaru_courier',
    'third_party'
);


ALTER TYPE "public"."shipping_method_enum" OWNER TO "postgres";


CREATE TYPE "public"."shipping_type_enum" AS ENUM (
    'direct',
    'preorder'
);


ALTER TYPE "public"."shipping_type_enum" OWNER TO "postgres";


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


CREATE TABLE IF NOT EXISTS "public"."admin_activity_log" (
    "log_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "admin_id" "uuid" NOT NULL,
    "action" "text" NOT NULL,
    "ip_address" character varying,
    "user_agent" "text",
    "created_at" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE "public"."admin_activity_log" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."admin_profile" (
    "admin_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" NOT NULL,
    "role" "public"."admin_role_enum" NOT NULL,
    "position" "text",
    "photo" "text",
    "created_at" timestamp without time zone DEFAULT "now"(),
    "updated_at" timestamp without time zone DEFAULT "now"(),
    "deleted_at" timestamp without time zone
);


ALTER TABLE "public"."admin_profile" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."cart" (
    "cart_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid",
    "product_id" "uuid",
    "service_id" "uuid",
    "item_type" "public"."item_type_enum",
    "quantity" integer NOT NULL,
    "note" "text",
    "created_at" timestamp without time zone DEFAULT "now"(),
    "updated_at" timestamp without time zone DEFAULT "now"(),
    "deleted_at" timestamp without time zone
);


ALTER TABLE "public"."cart" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."courier" (
    "courier_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" NOT NULL,
    "is_internal" boolean DEFAULT false,
    "created_at" timestamp without time zone DEFAULT "now"(),
    "updated_at" timestamp without time zone DEFAULT "now"()
);


ALTER TABLE "public"."courier" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."delivery" (
    "delivery_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "order_id" "uuid",
    "courier_id" "uuid",
    "delivery_status" "public"."delivery_status_enum",
    "courier_name" "text",
    "courier_contact" "text",
    "delivery_date" timestamp without time zone,
    "note" "text",
    "created_at" timestamp without time zone DEFAULT "now"(),
    "updated_at" timestamp without time zone DEFAULT "now"()
);


ALTER TABLE "public"."delivery" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."invoice" (
    "invoice_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "order_id" "uuid",
    "invoice_number" "text",
    "total_amount" numeric,
    "payment_status" "public"."payment_status_enum",
    "print_date" timestamp without time zone,
    "file_url" "text",
    "created_at" timestamp without time zone DEFAULT "now"(),
    "updated_at" timestamp without time zone DEFAULT "now"(),
    "deleted_at" timestamp without time zone
);


ALTER TABLE "public"."invoice" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."news" (
    "news_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "title" "text" NOT NULL,
    "content" "text" NOT NULL,
    "image_url" "text",
    "created_by" "uuid",
    "created_at" timestamp without time zone DEFAULT "now"(),
    "updated_at" timestamp without time zone DEFAULT "now"(),
    "deleted_at" timestamp without time zone
);


ALTER TABLE "public"."news" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."notification" (
    "notification_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid",
    "message" "text",
    "is_read" boolean DEFAULT false,
    "created_at" timestamp without time zone DEFAULT "now"()
);


ALTER TABLE "public"."notification" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."order_detail" (
    "detail_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "order_id" "uuid",
    "item_type" "public"."item_type_enum",
    "product_id" "uuid",
    "service_id" "uuid",
    "quantity" integer,
    "unit_price" integer,
    "subtotal" integer,
    "created_at" timestamp without time zone DEFAULT "now"(),
    "updated_at" timestamp without time zone DEFAULT "now"(),
    "deleted_at" timestamp without time zone
);


ALTER TABLE "public"."order_detail" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."orders" (
    "order_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid",
    "address_id" "uuid",
    "shipping_method" "public"."shipping_method_enum",
    "payment_method" "public"."payment_method_enum",
    "order_status" "public"."order_status_enum" DEFAULT 'pending'::"public"."order_status_enum",
    "total_price" integer,
    "shipping_cost" integer,
    "created_at" timestamp without time zone DEFAULT "now"(),
    "updated_at" timestamp without time zone DEFAULT "now"(),
    "deleted_at" timestamp without time zone,
    "shipping_type" "public"."shipping_type_enum" DEFAULT 'direct'::"public"."shipping_type_enum"
);


ALTER TABLE "public"."orders" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."payment" (
    "payment_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "order_id" "uuid",
    "va_number" "text",
    "bank" "text",
    "payment_status" "public"."payment_status_enum",
    "payment_time" timestamp without time zone,
    "created_at" timestamp without time zone DEFAULT "now"(),
    "updated_at" timestamp without time zone DEFAULT "now"(),
    "deleted_at" timestamp without time zone
);


ALTER TABLE "public"."payment" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."product" (
    "product_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "product_name" "text" NOT NULL,
    "product_category" "public"."product_category_enum",
    "description" "text",
    "price" integer NOT NULL,
    "stock" integer NOT NULL,
    "weight" integer,
    "image_url" "text",
    "created_by" "uuid",
    "created_at" timestamp without time zone DEFAULT "now"(),
    "updated_at" timestamp without time zone DEFAULT "now"(),
    "deleted_at" timestamp without time zone
);


ALTER TABLE "public"."product" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."service" (
    "service_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "service_name" "text" NOT NULL,
    "description" "text",
    "price" integer NOT NULL,
    "schedule" "text",
    "image_url" "text",
    "created_by" "uuid",
    "created_at" timestamp without time zone DEFAULT "now"(),
    "updated_at" timestamp without time zone DEFAULT "now"(),
    "deleted_at" timestamp without time zone
);


ALTER TABLE "public"."service" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."store_location" (
    "store_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "address" "text",
    "latitude" numeric,
    "longitude" numeric,
    "created_at" timestamp without time zone DEFAULT "now"(),
    "updated_at" timestamp without time zone DEFAULT "now"()
);


ALTER TABLE "public"."store_location" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."user_address" (
    "address_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid",
    "label" "text",
    "full_address" "text",
    "district" "text",
    "city" "text",
    "province" "text",
    "postal_code" "text",
    "recipient_phone" "text",
    "latitude" numeric,
    "longitude" numeric,
    "created_at" timestamp without time zone DEFAULT "now"(),
    "updated_at" timestamp without time zone DEFAULT "now"(),
    "deleted_at" timestamp without time zone
);


ALTER TABLE "public"."user_address" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."user_profile" (
    "user_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" NOT NULL,
    "address" "text",
    "phone_number" "text",
    "photo" "text",
    "created_at" timestamp without time zone DEFAULT "now"(),
    "updated_at" timestamp without time zone DEFAULT "now"(),
    "deleted_at" timestamp without time zone
);


ALTER TABLE "public"."user_profile" OWNER TO "postgres";


ALTER TABLE ONLY "public"."user_address"
    ADD CONSTRAINT "alamat_pengguna_pkey" PRIMARY KEY ("address_id");



ALTER TABLE ONLY "public"."news"
    ADD CONSTRAINT "berita_pkey" PRIMARY KEY ("news_id");



ALTER TABLE ONLY "public"."order_detail"
    ADD CONSTRAINT "detail_pesanan_pkey" PRIMARY KEY ("detail_id");



ALTER TABLE ONLY "public"."invoice"
    ADD CONSTRAINT "invoice_nomor_invoice_key" UNIQUE ("invoice_number");



ALTER TABLE ONLY "public"."service"
    ADD CONSTRAINT "jasa_pkey" PRIMARY KEY ("service_id");



ALTER TABLE ONLY "public"."cart"
    ADD CONSTRAINT "keranjang_pkey" PRIMARY KEY ("cart_id");



ALTER TABLE ONLY "public"."courier"
    ADD CONSTRAINT "kurir_pkey" PRIMARY KEY ("courier_id");



ALTER TABLE ONLY "public"."admin_activity_log"
    ADD CONSTRAINT "log_activity_admin_pkey" PRIMARY KEY ("log_id");



ALTER TABLE ONLY "public"."store_location"
    ADD CONSTRAINT "lokasi_toko_pkey" PRIMARY KEY ("store_id");



ALTER TABLE ONLY "public"."notification"
    ADD CONSTRAINT "notifikasi_pkey" PRIMARY KEY ("notification_id");



ALTER TABLE ONLY "public"."payment"
    ADD CONSTRAINT "pembayaran_pkey" PRIMARY KEY ("payment_id");



ALTER TABLE ONLY "public"."delivery"
    ADD CONSTRAINT "pengiriman_pkey" PRIMARY KEY ("delivery_id");



ALTER TABLE ONLY "public"."orders"
    ADD CONSTRAINT "pesanan_pkey" PRIMARY KEY ("order_id");



ALTER TABLE ONLY "public"."product"
    ADD CONSTRAINT "produk_pkey" PRIMARY KEY ("product_id");



ALTER TABLE ONLY "public"."admin_profile"
    ADD CONSTRAINT "profile_admin_pkey" PRIMARY KEY ("admin_id");



ALTER TABLE ONLY "public"."user_profile"
    ADD CONSTRAINT "profile_user_pkey" PRIMARY KEY ("user_id");



ALTER TABLE ONLY "public"."invoice"
    ADD CONSTRAINT "tagihan_pkey" PRIMARY KEY ("invoice_id");



CREATE OR REPLACE TRIGGER "trigger_history_pembayaran" AFTER UPDATE ON "public"."payment" FOR EACH ROW EXECUTE FUNCTION "public"."insert_history_pembayaran"();



CREATE OR REPLACE TRIGGER "trigger_history_pesanan" AFTER UPDATE ON "public"."orders" FOR EACH ROW EXECUTE FUNCTION "public"."insert_history_pesanan"();



ALTER TABLE ONLY "public"."admin_activity_log"
    ADD CONSTRAINT "admin_activity_log_admin_id_fkey" FOREIGN KEY ("admin_id") REFERENCES "public"."admin_profile"("admin_id");



ALTER TABLE ONLY "public"."user_address"
    ADD CONSTRAINT "alamat_pengguna_id_pengguna_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."user_profile"("user_id");



ALTER TABLE ONLY "public"."news"
    ADD CONSTRAINT "berita_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."admin_profile"("admin_id");



ALTER TABLE ONLY "public"."order_detail"
    ADD CONSTRAINT "detail_pesanan_id_jasa_fkey" FOREIGN KEY ("service_id") REFERENCES "public"."service"("service_id");



ALTER TABLE ONLY "public"."order_detail"
    ADD CONSTRAINT "detail_pesanan_id_pesanan_fkey" FOREIGN KEY ("order_id") REFERENCES "public"."orders"("order_id");



ALTER TABLE ONLY "public"."order_detail"
    ADD CONSTRAINT "detail_pesanan_id_produk_fkey" FOREIGN KEY ("product_id") REFERENCES "public"."product"("product_id");



ALTER TABLE ONLY "public"."admin_profile"
    ADD CONSTRAINT "fk_admin_auth" FOREIGN KEY ("admin_id") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "public"."user_profile"
    ADD CONSTRAINT "fk_user_auth" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "public"."service"
    ADD CONSTRAINT "jasa_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."admin_profile"("admin_id");



ALTER TABLE ONLY "public"."cart"
    ADD CONSTRAINT "keranjang_id_jasa_fkey" FOREIGN KEY ("service_id") REFERENCES "public"."service"("service_id");



ALTER TABLE ONLY "public"."cart"
    ADD CONSTRAINT "keranjang_id_pengguna_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."user_profile"("user_id");



ALTER TABLE ONLY "public"."cart"
    ADD CONSTRAINT "keranjang_id_produk_fkey" FOREIGN KEY ("product_id") REFERENCES "public"."product"("product_id");



ALTER TABLE ONLY "public"."notification"
    ADD CONSTRAINT "notifikasi_id_pengguna_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."user_profile"("user_id");



ALTER TABLE ONLY "public"."payment"
    ADD CONSTRAINT "pembayaran_id_pesanan_fkey" FOREIGN KEY ("order_id") REFERENCES "public"."orders"("order_id");



ALTER TABLE ONLY "public"."delivery"
    ADD CONSTRAINT "pengiriman_id_kurir_fkey" FOREIGN KEY ("courier_id") REFERENCES "public"."courier"("courier_id");



ALTER TABLE ONLY "public"."delivery"
    ADD CONSTRAINT "pengiriman_id_pesanan_fkey" FOREIGN KEY ("order_id") REFERENCES "public"."orders"("order_id");



ALTER TABLE ONLY "public"."orders"
    ADD CONSTRAINT "pesanan_id_alamat_pengguna_fkey" FOREIGN KEY ("address_id") REFERENCES "public"."user_address"("address_id");



ALTER TABLE ONLY "public"."orders"
    ADD CONSTRAINT "pesanan_id_pengguna_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."user_profile"("user_id");



ALTER TABLE ONLY "public"."product"
    ADD CONSTRAINT "produk_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."admin_profile"("admin_id");



ALTER TABLE ONLY "public"."invoice"
    ADD CONSTRAINT "tagihan_id_pesanan_fkey" FOREIGN KEY ("order_id") REFERENCES "public"."orders"("order_id");



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



GRANT ALL ON TABLE "public"."admin_activity_log" TO "anon";
GRANT ALL ON TABLE "public"."admin_activity_log" TO "authenticated";
GRANT ALL ON TABLE "public"."admin_activity_log" TO "service_role";



GRANT ALL ON TABLE "public"."admin_profile" TO "anon";
GRANT ALL ON TABLE "public"."admin_profile" TO "authenticated";
GRANT ALL ON TABLE "public"."admin_profile" TO "service_role";



GRANT ALL ON TABLE "public"."cart" TO "anon";
GRANT ALL ON TABLE "public"."cart" TO "authenticated";
GRANT ALL ON TABLE "public"."cart" TO "service_role";



GRANT ALL ON TABLE "public"."courier" TO "anon";
GRANT ALL ON TABLE "public"."courier" TO "authenticated";
GRANT ALL ON TABLE "public"."courier" TO "service_role";



GRANT ALL ON TABLE "public"."delivery" TO "anon";
GRANT ALL ON TABLE "public"."delivery" TO "authenticated";
GRANT ALL ON TABLE "public"."delivery" TO "service_role";



GRANT ALL ON TABLE "public"."invoice" TO "anon";
GRANT ALL ON TABLE "public"."invoice" TO "authenticated";
GRANT ALL ON TABLE "public"."invoice" TO "service_role";



GRANT ALL ON TABLE "public"."news" TO "anon";
GRANT ALL ON TABLE "public"."news" TO "authenticated";
GRANT ALL ON TABLE "public"."news" TO "service_role";



GRANT ALL ON TABLE "public"."notification" TO "anon";
GRANT ALL ON TABLE "public"."notification" TO "authenticated";
GRANT ALL ON TABLE "public"."notification" TO "service_role";



GRANT ALL ON TABLE "public"."order_detail" TO "anon";
GRANT ALL ON TABLE "public"."order_detail" TO "authenticated";
GRANT ALL ON TABLE "public"."order_detail" TO "service_role";



GRANT ALL ON TABLE "public"."orders" TO "anon";
GRANT ALL ON TABLE "public"."orders" TO "authenticated";
GRANT ALL ON TABLE "public"."orders" TO "service_role";



GRANT ALL ON TABLE "public"."payment" TO "anon";
GRANT ALL ON TABLE "public"."payment" TO "authenticated";
GRANT ALL ON TABLE "public"."payment" TO "service_role";



GRANT ALL ON TABLE "public"."product" TO "anon";
GRANT ALL ON TABLE "public"."product" TO "authenticated";
GRANT ALL ON TABLE "public"."product" TO "service_role";



GRANT ALL ON TABLE "public"."service" TO "anon";
GRANT ALL ON TABLE "public"."service" TO "authenticated";
GRANT ALL ON TABLE "public"."service" TO "service_role";



GRANT ALL ON TABLE "public"."store_location" TO "anon";
GRANT ALL ON TABLE "public"."store_location" TO "authenticated";
GRANT ALL ON TABLE "public"."store_location" TO "service_role";



GRANT ALL ON TABLE "public"."user_address" TO "anon";
GRANT ALL ON TABLE "public"."user_address" TO "authenticated";
GRANT ALL ON TABLE "public"."user_address" TO "service_role";



GRANT ALL ON TABLE "public"."user_profile" TO "anon";
GRANT ALL ON TABLE "public"."user_profile" TO "authenticated";
GRANT ALL ON TABLE "public"."user_profile" TO "service_role";



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
