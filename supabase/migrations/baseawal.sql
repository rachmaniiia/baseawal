

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
    "first_name" "text" NOT NULL,
    "role" "public"."admin_role_enum" NOT NULL,
    "position" "text",
    "photo" "text",
    "created_at" timestamp without time zone DEFAULT "now"(),
    "updated_at" timestamp without time zone DEFAULT "now"(),
    "deleted_at" timestamp without time zone,
    "last_name" "text"
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
    "unit_price" numeric,
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
    "total_price" numeric,
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
    "payment_status" "public"."payment_status_enum",
    "payment_time" timestamp without time zone,
    "created_at" timestamp without time zone DEFAULT "now"(),
    "updated_at" timestamp without time zone DEFAULT "now"(),
    "deleted_at" timestamp without time zone,
    "reference_no" character varying
);


ALTER TABLE "public"."payment" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."product" (
    "product_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "product_name" "text" NOT NULL,
    "product_category" "public"."product_category_enum",
    "description" "text",
    "price" numeric NOT NULL,
    "stock" integer NOT NULL,
    "weight" numeric,
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
    "price" numeric NOT NULL,
    "image_url" "text",
    "created_by" "uuid",
    "created_at" timestamp without time zone DEFAULT "now"(),
    "updated_at" timestamp without time zone DEFAULT "now"(),
    "deleted_at" timestamp without time zone,
    "stock" integer
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
    "first_name" "text" NOT NULL,
    "phone_number" "text",
    "photo" "text",
    "created_at" timestamp without time zone DEFAULT "now"(),
    "updated_at" timestamp without time zone DEFAULT "now"(),
    "deleted_at" timestamp without time zone,
    "last_name" "text"
);


ALTER TABLE "public"."user_profile" OWNER TO "postgres";


ALTER TABLE ONLY "public"."admin_activity_log"
    ADD CONSTRAINT "admin_activity_log_pkey" PRIMARY KEY ("log_id");



ALTER TABLE ONLY "public"."admin_profile"
    ADD CONSTRAINT "admin_profile_pkey" PRIMARY KEY ("admin_id");



ALTER TABLE ONLY "public"."cart"
    ADD CONSTRAINT "cart_pkey" PRIMARY KEY ("cart_id");



ALTER TABLE ONLY "public"."courier"
    ADD CONSTRAINT "courier_pkey" PRIMARY KEY ("courier_id");



ALTER TABLE ONLY "public"."delivery"
    ADD CONSTRAINT "delivery_pkey" PRIMARY KEY ("delivery_id");



ALTER TABLE ONLY "public"."invoice"
    ADD CONSTRAINT "invoice_invoice_number_key" UNIQUE ("invoice_number");



ALTER TABLE ONLY "public"."invoice"
    ADD CONSTRAINT "invoice_pkey" PRIMARY KEY ("invoice_id");



ALTER TABLE ONLY "public"."news"
    ADD CONSTRAINT "news_pkey" PRIMARY KEY ("news_id");



ALTER TABLE ONLY "public"."notification"
    ADD CONSTRAINT "notification_pkey" PRIMARY KEY ("notification_id");



ALTER TABLE ONLY "public"."order_detail"
    ADD CONSTRAINT "order_detail_pkey" PRIMARY KEY ("detail_id");



ALTER TABLE ONLY "public"."orders"
    ADD CONSTRAINT "orders_pkey" PRIMARY KEY ("order_id");



ALTER TABLE ONLY "public"."payment"
    ADD CONSTRAINT "payment_pkey" PRIMARY KEY ("payment_id");



ALTER TABLE ONLY "public"."product"
    ADD CONSTRAINT "product_pkey" PRIMARY KEY ("product_id");



ALTER TABLE ONLY "public"."service"
    ADD CONSTRAINT "service_pkey" PRIMARY KEY ("service_id");



ALTER TABLE ONLY "public"."store_location"
    ADD CONSTRAINT "store_location_pkey" PRIMARY KEY ("store_id");



ALTER TABLE ONLY "public"."user_address"
    ADD CONSTRAINT "user_address_pkey" PRIMARY KEY ("address_id");



ALTER TABLE ONLY "public"."user_profile"
    ADD CONSTRAINT "user_profile_pkey" PRIMARY KEY ("user_id");



ALTER TABLE ONLY "public"."admin_activity_log"
    ADD CONSTRAINT "admin_activity_log_admin_id_fkey" FOREIGN KEY ("admin_id") REFERENCES "public"."admin_profile"("admin_id");



ALTER TABLE ONLY "public"."admin_profile"
    ADD CONSTRAINT "admin_profile_auth_id_fkey" FOREIGN KEY ("admin_id") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "public"."cart"
    ADD CONSTRAINT "cart_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "public"."product"("product_id");



ALTER TABLE ONLY "public"."cart"
    ADD CONSTRAINT "cart_service_id_fkey" FOREIGN KEY ("service_id") REFERENCES "public"."service"("service_id");



ALTER TABLE ONLY "public"."cart"
    ADD CONSTRAINT "cart_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."user_profile"("user_id");



ALTER TABLE ONLY "public"."delivery"
    ADD CONSTRAINT "delivery_courier_id_fkey" FOREIGN KEY ("courier_id") REFERENCES "public"."courier"("courier_id");



ALTER TABLE ONLY "public"."delivery"
    ADD CONSTRAINT "delivery_order_id_fkey" FOREIGN KEY ("order_id") REFERENCES "public"."orders"("order_id");



ALTER TABLE ONLY "public"."user_profile"
    ADD CONSTRAINT "fk_user_auth" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "public"."invoice"
    ADD CONSTRAINT "invoice_order_id_fkey" FOREIGN KEY ("order_id") REFERENCES "public"."orders"("order_id");



ALTER TABLE ONLY "public"."news"
    ADD CONSTRAINT "news_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."admin_profile"("admin_id");



ALTER TABLE ONLY "public"."notification"
    ADD CONSTRAINT "notification_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."user_profile"("user_id");



ALTER TABLE ONLY "public"."order_detail"
    ADD CONSTRAINT "order_detail_order_id_fkey" FOREIGN KEY ("order_id") REFERENCES "public"."orders"("order_id");



ALTER TABLE ONLY "public"."order_detail"
    ADD CONSTRAINT "order_detail_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "public"."product"("product_id");



ALTER TABLE ONLY "public"."order_detail"
    ADD CONSTRAINT "order_detail_service_id_fkey" FOREIGN KEY ("service_id") REFERENCES "public"."service"("service_id");



ALTER TABLE ONLY "public"."orders"
    ADD CONSTRAINT "orders_address_id_fkey" FOREIGN KEY ("address_id") REFERENCES "public"."user_address"("address_id");



ALTER TABLE ONLY "public"."orders"
    ADD CONSTRAINT "orders_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."user_profile"("user_id");



ALTER TABLE ONLY "public"."payment"
    ADD CONSTRAINT "payment_order_id_fkey" FOREIGN KEY ("order_id") REFERENCES "public"."orders"("order_id");



ALTER TABLE ONLY "public"."product"
    ADD CONSTRAINT "product_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."admin_profile"("admin_id");



ALTER TABLE ONLY "public"."service"
    ADD CONSTRAINT "service_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."admin_profile"("admin_id");



ALTER TABLE ONLY "public"."user_address"
    ADD CONSTRAINT "user_address_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."user_profile"("user_id");



CREATE POLICY "Admins can create news" ON "public"."news" FOR INSERT TO "authenticated" WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."admin_profile"
  WHERE (("admin_profile"."admin_id" = ( SELECT "auth"."uid"() AS "uid")) AND ("admin_profile"."role" = 'admin'::"public"."admin_role_enum")))));



CREATE POLICY "Admins can create products" ON "public"."product" FOR INSERT TO "authenticated" WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."admin_profile"
  WHERE (("admin_profile"."admin_id" = ( SELECT "auth"."uid"() AS "uid")) AND ("admin_profile"."role" = 'admin'::"public"."admin_role_enum")))));



CREATE POLICY "Admins can create services" ON "public"."service" FOR INSERT TO "authenticated" WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."admin_profile"
  WHERE (("admin_profile"."admin_id" = ( SELECT "auth"."uid"() AS "uid")) AND ("admin_profile"."role" = 'admin'::"public"."admin_role_enum")))));



CREATE POLICY "Admins can delete news" ON "public"."news" FOR DELETE TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."admin_profile"
  WHERE (("admin_profile"."admin_id" = ( SELECT "auth"."uid"() AS "uid")) AND ("admin_profile"."role" = 'admin'::"public"."admin_role_enum")))));



CREATE POLICY "Admins can delete orders" ON "public"."orders" FOR DELETE TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."admin_profile"
  WHERE (("admin_profile"."admin_id" = ( SELECT "auth"."uid"() AS "uid")) AND ("admin_profile"."role" = 'admin'::"public"."admin_role_enum")))));



CREATE POLICY "Admins can delete products" ON "public"."product" FOR DELETE TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."admin_profile"
  WHERE (("admin_profile"."admin_id" = ( SELECT "auth"."uid"() AS "uid")) AND ("admin_profile"."role" = 'admin'::"public"."admin_role_enum")))));



CREATE POLICY "Admins can delete services" ON "public"."service" FOR DELETE TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."admin_profile"
  WHERE (("admin_profile"."admin_id" = ( SELECT "auth"."uid"() AS "uid")) AND ("admin_profile"."role" = 'admin'::"public"."admin_role_enum")))));



CREATE POLICY "Admins can delete store locations" ON "public"."store_location" FOR DELETE TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."admin_profile"
  WHERE (("admin_profile"."admin_id" = ( SELECT "auth"."uid"() AS "uid")) AND ("admin_profile"."role" = 'admin'::"public"."admin_role_enum")))));



CREATE POLICY "Admins can insert store locations" ON "public"."store_location" FOR INSERT TO "authenticated" WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."admin_profile"
  WHERE (("admin_profile"."admin_id" = ( SELECT "auth"."uid"() AS "uid")) AND ("admin_profile"."role" = 'admin'::"public"."admin_role_enum")))));



CREATE POLICY "Admins can manage couriers_delete" ON "public"."courier" FOR DELETE TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."admin_profile"
  WHERE (("admin_profile"."admin_id" = ( SELECT "auth"."uid"() AS "uid")) AND ("admin_profile"."role" = 'admin'::"public"."admin_role_enum")))));



CREATE POLICY "Admins can manage couriers_dml" ON "public"."courier" FOR INSERT TO "authenticated" WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."admin_profile"
  WHERE (("admin_profile"."admin_id" = ( SELECT "auth"."uid"() AS "uid")) AND ("admin_profile"."role" = 'admin'::"public"."admin_role_enum")))));



CREATE POLICY "Admins can manage couriers_update" ON "public"."courier" FOR UPDATE TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."admin_profile"
  WHERE (("admin_profile"."admin_id" = ( SELECT "auth"."uid"() AS "uid")) AND ("admin_profile"."role" = 'admin'::"public"."admin_role_enum"))))) WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."admin_profile"
  WHERE (("admin_profile"."admin_id" = ( SELECT "auth"."uid"() AS "uid")) AND ("admin_profile"."role" = 'admin'::"public"."admin_role_enum")))));



CREATE POLICY "Admins can update admin profiles" ON "public"."admin_profile" FOR UPDATE TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."admin_profile" "admin_profile_1"
  WHERE (("admin_profile_1"."admin_id" = ( SELECT "auth"."uid"() AS "uid")) AND ("admin_profile_1"."role" = 'admin'::"public"."admin_role_enum"))))) WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."admin_profile" "admin_profile_1"
  WHERE (("admin_profile_1"."admin_id" = ( SELECT "auth"."uid"() AS "uid")) AND ("admin_profile_1"."role" = 'admin'::"public"."admin_role_enum")))));



CREATE POLICY "Admins can update invoices" ON "public"."invoice" FOR UPDATE TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."admin_profile"
  WHERE (("admin_profile"."admin_id" = ( SELECT "auth"."uid"() AS "uid")) AND ("admin_profile"."role" = 'admin'::"public"."admin_role_enum")))));



CREATE POLICY "Admins can update news" ON "public"."news" FOR UPDATE TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."admin_profile"
  WHERE (("admin_profile"."admin_id" = ( SELECT "auth"."uid"() AS "uid")) AND ("admin_profile"."role" = 'admin'::"public"."admin_role_enum"))))) WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."admin_profile"
  WHERE (("admin_profile"."admin_id" = ( SELECT "auth"."uid"() AS "uid")) AND ("admin_profile"."role" = 'admin'::"public"."admin_role_enum")))));



CREATE POLICY "Admins can update orders" ON "public"."orders" FOR UPDATE TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."admin_profile"
  WHERE (("admin_profile"."admin_id" = ( SELECT "auth"."uid"() AS "uid")) AND ("admin_profile"."role" = 'admin'::"public"."admin_role_enum")))));



CREATE POLICY "Admins can update payments" ON "public"."payment" FOR UPDATE TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."admin_profile"
  WHERE (("admin_profile"."admin_id" = ( SELECT "auth"."uid"() AS "uid")) AND ("admin_profile"."role" = 'admin'::"public"."admin_role_enum")))));



CREATE POLICY "Admins can update products" ON "public"."product" FOR UPDATE TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."admin_profile"
  WHERE (("admin_profile"."admin_id" = ( SELECT "auth"."uid"() AS "uid")) AND ("admin_profile"."role" = 'admin'::"public"."admin_role_enum"))))) WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."admin_profile"
  WHERE (("admin_profile"."admin_id" = ( SELECT "auth"."uid"() AS "uid")) AND ("admin_profile"."role" = 'admin'::"public"."admin_role_enum")))));



CREATE POLICY "Admins can update services" ON "public"."service" FOR UPDATE TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."admin_profile"
  WHERE (("admin_profile"."admin_id" = ( SELECT "auth"."uid"() AS "uid")) AND ("admin_profile"."role" = 'admin'::"public"."admin_role_enum"))))) WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."admin_profile"
  WHERE (("admin_profile"."admin_id" = ( SELECT "auth"."uid"() AS "uid")) AND ("admin_profile"."role" = 'admin'::"public"."admin_role_enum")))));



CREATE POLICY "Admins can update store locations" ON "public"."store_location" FOR UPDATE TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."admin_profile"
  WHERE (("admin_profile"."admin_id" = ( SELECT "auth"."uid"() AS "uid")) AND ("admin_profile"."role" = 'admin'::"public"."admin_role_enum"))))) WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."admin_profile"
  WHERE (("admin_profile"."admin_id" = ( SELECT "auth"."uid"() AS "uid")) AND ("admin_profile"."role" = 'admin'::"public"."admin_role_enum")))));



CREATE POLICY "Admins can view activity logs" ON "public"."admin_activity_log" FOR SELECT TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."admin_profile"
  WHERE (("admin_profile"."admin_id" = ( SELECT "auth"."uid"() AS "uid")) AND ("admin_profile"."role" = 'admin'::"public"."admin_role_enum")))));



CREATE POLICY "Admins can view all admin profiles" ON "public"."admin_profile" FOR SELECT TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."admin_profile" "admin_profile_1"
  WHERE (("admin_profile_1"."admin_id" = ( SELECT "auth"."uid"() AS "uid")) AND ("admin_profile_1"."role" = 'admin'::"public"."admin_role_enum")))));



CREATE POLICY "Couriers can update their deliveries" ON "public"."delivery" FOR UPDATE TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."admin_profile"
  WHERE (("admin_profile"."admin_id" = ( SELECT "auth"."uid"() AS "uid")) AND ("admin_profile"."role" = 'operator'::"public"."admin_role_enum")))));



CREATE POLICY "Everyone can view couriers" ON "public"."courier" FOR SELECT USING (true);



CREATE POLICY "Everyone can view news" ON "public"."news" FOR SELECT USING (true);



CREATE POLICY "Everyone can view products" ON "public"."product" FOR SELECT USING (true);



CREATE POLICY "Everyone can view services" ON "public"."service" FOR SELECT USING (true);



CREATE POLICY "Everyone can view store locations" ON "public"."store_location" FOR SELECT USING (true);



CREATE POLICY "Users and Admins can view deliveries" ON "public"."delivery" FOR SELECT TO "authenticated" USING (((EXISTS ( SELECT 1
   FROM "public"."orders"
  WHERE (("orders"."order_id" = "delivery"."order_id") AND ("orders"."user_id" = ( SELECT "auth"."uid"() AS "uid"))))) OR (EXISTS ( SELECT 1
   FROM "public"."admin_profile"
  WHERE (("admin_profile"."admin_id" = ( SELECT "auth"."uid"() AS "uid")) AND ("admin_profile"."role" = 'admin'::"public"."admin_role_enum"))))));



CREATE POLICY "Users and Admins can view invoices" ON "public"."invoice" FOR SELECT TO "authenticated" USING (((EXISTS ( SELECT 1
   FROM "public"."orders"
  WHERE (("orders"."order_id" = "invoice"."order_id") AND ("orders"."user_id" = ( SELECT "auth"."uid"() AS "uid"))))) OR (EXISTS ( SELECT 1
   FROM "public"."admin_profile"
  WHERE (("admin_profile"."admin_id" = ( SELECT "auth"."uid"() AS "uid")) AND ("admin_profile"."role" = 'admin'::"public"."admin_role_enum"))))));



CREATE POLICY "Users and Admins can view order details" ON "public"."order_detail" FOR SELECT TO "authenticated" USING (((EXISTS ( SELECT 1
   FROM "public"."orders"
  WHERE (("orders"."order_id" = "order_detail"."order_id") AND ("orders"."user_id" = ( SELECT "auth"."uid"() AS "uid"))))) OR (EXISTS ( SELECT 1
   FROM "public"."admin_profile"
  WHERE (("admin_profile"."admin_id" = ( SELECT "auth"."uid"() AS "uid")) AND ("admin_profile"."role" = 'admin'::"public"."admin_role_enum"))))));



CREATE POLICY "Users and Admins can view orders" ON "public"."orders" FOR SELECT TO "authenticated" USING (((( SELECT "auth"."uid"() AS "uid") = "user_id") OR (EXISTS ( SELECT 1
   FROM "public"."admin_profile"
  WHERE (("admin_profile"."admin_id" = ( SELECT "auth"."uid"() AS "uid")) AND ("admin_profile"."role" = 'admin'::"public"."admin_role_enum"))))));



CREATE POLICY "Users and Admins can view payments" ON "public"."payment" FOR SELECT TO "authenticated" USING (((EXISTS ( SELECT 1
   FROM "public"."orders"
  WHERE (("orders"."order_id" = "payment"."order_id") AND ("orders"."user_id" = ( SELECT "auth"."uid"() AS "uid"))))) OR (EXISTS ( SELECT 1
   FROM "public"."admin_profile"
  WHERE (("admin_profile"."admin_id" = ( SELECT "auth"."uid"() AS "uid")) AND ("admin_profile"."role" = 'admin'::"public"."admin_role_enum"))))));



CREATE POLICY "Users can add their own addresses" ON "public"."user_address" FOR INSERT TO "authenticated" WITH CHECK ((( SELECT "auth"."uid"() AS "uid") = "user_id"));



CREATE POLICY "Users can add to their own cart" ON "public"."cart" FOR INSERT TO "authenticated" WITH CHECK ((( SELECT "auth"."uid"() AS "uid") = "user_id"));



CREATE POLICY "Users can create orders" ON "public"."orders" FOR INSERT TO "authenticated" WITH CHECK ((( SELECT "auth"."uid"() AS "uid") = "user_id"));



CREATE POLICY "Users can create their own profile" ON "public"."user_profile" FOR INSERT TO "authenticated" WITH CHECK ((( SELECT "auth"."uid"() AS "uid") = "user_id"));



CREATE POLICY "Users can delete from their own cart" ON "public"."cart" FOR DELETE TO "authenticated" USING ((( SELECT "auth"."uid"() AS "uid") = "user_id"));



CREATE POLICY "Users can delete their own addresses" ON "public"."user_address" FOR DELETE TO "authenticated" USING ((( SELECT "auth"."uid"() AS "uid") = "user_id"));



CREATE POLICY "Users can delete their own profiles" ON "public"."user_profile" FOR DELETE TO "authenticated" USING ((( SELECT "auth"."uid"() AS "uid") = "user_id"));



CREATE POLICY "Users can update their own addresses" ON "public"."user_address" FOR UPDATE TO "authenticated" USING ((( SELECT "auth"."uid"() AS "uid") = "user_id")) WITH CHECK ((( SELECT "auth"."uid"() AS "uid") = "user_id"));



CREATE POLICY "Users can update their own cart" ON "public"."cart" FOR UPDATE TO "authenticated" USING ((( SELECT "auth"."uid"() AS "uid") = "user_id")) WITH CHECK ((( SELECT "auth"."uid"() AS "uid") = "user_id"));



CREATE POLICY "Users can update their own notifications" ON "public"."notification" FOR UPDATE TO "authenticated" USING ((( SELECT "auth"."uid"() AS "uid") = "user_id")) WITH CHECK ((( SELECT "auth"."uid"() AS "uid") = "user_id"));



CREATE POLICY "Users can update their own profiles" ON "public"."user_profile" FOR UPDATE TO "authenticated" USING ((( SELECT "auth"."uid"() AS "uid") = "user_id")) WITH CHECK ((( SELECT "auth"."uid"() AS "uid") = "user_id"));



CREATE POLICY "Users can view their own addresses" ON "public"."user_address" FOR SELECT TO "authenticated" USING ((( SELECT "auth"."uid"() AS "uid") = "user_id"));



CREATE POLICY "Users can view their own cart" ON "public"."cart" FOR SELECT TO "authenticated" USING ((( SELECT "auth"."uid"() AS "uid") = "user_id"));



CREATE POLICY "Users can view their own notifications" ON "public"."notification" FOR SELECT TO "authenticated" USING ((( SELECT "auth"."uid"() AS "uid") = "user_id"));



CREATE POLICY "Users can view their own profiles" ON "public"."user_profile" FOR SELECT TO "authenticated" USING ((( SELECT "auth"."uid"() AS "uid") = "user_id"));



ALTER TABLE "public"."admin_activity_log" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."admin_profile" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."cart" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."courier" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."delivery" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."invoice" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."news" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."notification" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."order_detail" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."orders" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."payment" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."product" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."service" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."store_location" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."user_address" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."user_profile" ENABLE ROW LEVEL SECURITY;


GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";



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
