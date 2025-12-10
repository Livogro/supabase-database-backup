


SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;


COMMENT ON SCHEMA "public" IS 'standard public schema';



CREATE EXTENSION IF NOT EXISTS "pg_graphql" WITH SCHEMA "graphql";






CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";






CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";






CREATE TYPE "public"."app_role" AS ENUM (
    'admin',
    'moderator',
    'user'
);


ALTER TYPE "public"."app_role" OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."handle_new_user"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
BEGIN
  -- Insert profile
  INSERT INTO public.profiles (user_id, email, role)
  VALUES (NEW.id, NEW.email, 'admin');
  
  -- Insert admin role
  INSERT INTO public.user_roles (user_id, role)
  VALUES (NEW.id, 'admin');
  
  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."handle_new_user"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."has_role"("_user_id" "uuid", "_role" "public"."app_role") RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.user_roles
    WHERE user_id = _user_id AND role = _role
  )
$$;


ALTER FUNCTION "public"."has_role"("_user_id" "uuid", "_role" "public"."app_role") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_updated_at_column"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public'
    AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."update_updated_at_column"() OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "public"."colouring_categories" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" NOT NULL,
    "description" "text",
    "thumbnail_url" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."colouring_categories" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."colouring_pages" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "title" "text" NOT NULL,
    "description" "text",
    "thumbnail_url" "text",
    "preview_url" "text",
    "download_url" "text",
    "file_type" "text" DEFAULT 'pdf'::"text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "category_id" "uuid",
    "jpg_url" "text",
    "pdf_url" "text"
);


ALTER TABLE "public"."colouring_pages" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."contact_submissions" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" NOT NULL,
    "email" "text" NOT NULL,
    "message" "text" NOT NULL,
    "status" "text" DEFAULT 'new'::"text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."contact_submissions" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."game_categories" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" NOT NULL,
    "description" "text",
    "thumbnail_url" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."game_categories" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."games" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "title" "text" NOT NULL,
    "description" "text",
    "category_id" "uuid",
    "html_content" "text",
    "thumbnail_url" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "css_url" "text",
    "js_url" "text"
);


ALTER TABLE "public"."games" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."giveaways" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "title" "text" NOT NULL,
    "description" "text",
    "instagram_url" "text" NOT NULL,
    "thumbnail_url" "text",
    "start_date" timestamp with time zone NOT NULL,
    "end_date" timestamp with time zone NOT NULL,
    "winners" "text",
    "prizes" "text"
);


ALTER TABLE "public"."giveaways" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."profiles" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "email" "text",
    "role" "text" DEFAULT 'admin'::"text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."profiles" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."site_settings" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "logo_url" "text",
    "site_title" "text" DEFAULT 'Smalsučių Pasaulis'::"text" NOT NULL,
    "hero_description" "text" DEFAULT 'A magical world of fun songs and creative colouring pages for kids!'::"text" NOT NULL,
    "latest_section_title" "text" DEFAULT 'Latest Additions'::"text" NOT NULL,
    "latest_section_description" "text" DEFAULT 'Check out our newest songs and colouring pages!'::"text" NOT NULL,
    "features_section_title" "text" DEFAULT 'What Makes Us Special'::"text" NOT NULL,
    "features_section_description" "text" DEFAULT 'Discover why kids and parents love our content'::"text" NOT NULL,
    "feature_1_title" "text" DEFAULT 'Educational Songs'::"text" NOT NULL,
    "feature_1_description" "text" DEFAULT 'Fun and educational songs that help children learn through music, with catchy melodies and meaningful lyrics.'::"text" NOT NULL,
    "feature_2_title" "text" DEFAULT 'Creative Activities'::"text" NOT NULL,
    "feature_2_description" "text" DEFAULT 'Free downloadable colouring pages that encourage creativity and provide hours of engaging offline fun.'::"text" NOT NULL,
    "feature_3_title" "text" DEFAULT 'Family-Friendly'::"text" NOT NULL,
    "feature_3_description" "text" DEFAULT 'Safe, age-appropriate content that brings families together and creates lasting memories.'::"text" NOT NULL,
    "cta_section_title" "text" DEFAULT 'Join the Fun!'::"text" NOT NULL,
    "cta_section_description" "text" DEFAULT 'Subscribe to our YouTube channel for new songs and activities. Follow us on social media to stay connected!'::"text" NOT NULL,
    "about_hero_title" "text" DEFAULT 'About Smalsučių Pasaulis'::"text" NOT NULL,
    "about_hero_description" "text" DEFAULT 'Welcome to Smalsučių Pasaulis - a creative space where children discover the joy of music and art!'::"text" NOT NULL,
    "about_mission_title" "text" DEFAULT 'Our Mission'::"text" NOT NULL,
    "about_mission_description" "text" DEFAULT 'We believe in the power of creativity and music to inspire young minds. Our mission is to provide high-quality, educational entertainment that sparks imagination and brings families together.'::"text" NOT NULL,
    "about_content_title" "text" DEFAULT 'What We Offer'::"text" NOT NULL,
    "about_content_description" "text" DEFAULT 'From catchy educational songs to beautiful colouring pages, we create content that children love and parents trust.'::"text" NOT NULL,
    "hero_bg_url" "text",
    "hero_logo_url" "text",
    "footer_brand_text" "text" DEFAULT 'Vaikų YouTube kanalas'::"text" NOT NULL,
    "footer_description" "text" DEFAULT 'Smagios dainos ir spalvinimo lapai vaikams. Edukacinė pramoga, skatinanti kūrybiškumą ir džiaugsmą.'::"text" NOT NULL,
    "footer_links_title" "text" DEFAULT 'Greitos nuorodos'::"text" NOT NULL,
    "footer_social_title" "text" DEFAULT 'Sekite mus'::"text" NOT NULL,
    "footer_social_description" "text" DEFAULT 'Prenumeruokite mūsų YouTube kanalą naujoms dainoms ir veikloms!'::"text" NOT NULL,
    "footer_youtube_url" "text" DEFAULT 'https://youtube.com/@smalsuciu'::"text" NOT NULL,
    "footer_instagram_url" "text" DEFAULT 'https://instagram.com/smalsuciu'::"text" NOT NULL,
    "footer_facebook_url" "text" DEFAULT 'https://facebook.com/smalsuciu'::"text" NOT NULL,
    "footer_email" "text" DEFAULT 'contact@smalsuciu.com'::"text" NOT NULL,
    "footer_copyright" "text" DEFAULT '© 2024 Smalsučių Pasaulis. Visos teisės saugomos. Sukurta su ❤️ vaikams.'::"text" NOT NULL,
    "maintenance_enabled" boolean DEFAULT false NOT NULL,
    "maintenance_title" "text" DEFAULT 'Svetainė atnaujinama'::"text" NOT NULL,
    "maintenance_description" "text" DEFAULT 'Šiuo metu atliekami techniniai darbai. Greitai grįšime!'::"text" NOT NULL,
    "maintenance_bypass_key" "text" DEFAULT 'admin-access-2024'::"text" NOT NULL
);


ALTER TABLE "public"."site_settings" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."song_tags" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "song_id" "uuid" NOT NULL,
    "tag_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."song_tags" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."songs" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "title" "text" NOT NULL,
    "youtube_url" "text" NOT NULL,
    "youtube_id" "text" NOT NULL,
    "thumbnail_url" "text",
    "lyrics" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."songs" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."tags" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."tags" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."user_roles" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "role" "public"."app_role" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."user_roles" OWNER TO "postgres";


ALTER TABLE ONLY "public"."colouring_categories"
    ADD CONSTRAINT "colouring_categories_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."colouring_pages"
    ADD CONSTRAINT "colouring_pages_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."contact_submissions"
    ADD CONSTRAINT "contact_submissions_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."game_categories"
    ADD CONSTRAINT "game_categories_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."games"
    ADD CONSTRAINT "games_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."giveaways"
    ADD CONSTRAINT "giveaways_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_user_id_key" UNIQUE ("user_id");



ALTER TABLE ONLY "public"."site_settings"
    ADD CONSTRAINT "site_settings_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."song_tags"
    ADD CONSTRAINT "song_tags_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."song_tags"
    ADD CONSTRAINT "song_tags_song_id_tag_id_key" UNIQUE ("song_id", "tag_id");



ALTER TABLE ONLY "public"."songs"
    ADD CONSTRAINT "songs_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."tags"
    ADD CONSTRAINT "tags_name_key" UNIQUE ("name");



ALTER TABLE ONLY "public"."tags"
    ADD CONSTRAINT "tags_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."user_roles"
    ADD CONSTRAINT "user_roles_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."user_roles"
    ADD CONSTRAINT "user_roles_user_id_role_key" UNIQUE ("user_id", "role");



CREATE INDEX "idx_games_category_id" ON "public"."games" USING "btree" ("category_id");



CREATE INDEX "idx_song_tags_song_id" ON "public"."song_tags" USING "btree" ("song_id");



CREATE INDEX "idx_song_tags_tag_id" ON "public"."song_tags" USING "btree" ("tag_id");



CREATE OR REPLACE TRIGGER "update_colouring_categories_updated_at" BEFORE UPDATE ON "public"."colouring_categories" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_colouring_pages_updated_at" BEFORE UPDATE ON "public"."colouring_pages" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_contact_submissions_updated_at" BEFORE UPDATE ON "public"."contact_submissions" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_game_categories_updated_at" BEFORE UPDATE ON "public"."game_categories" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_games_updated_at" BEFORE UPDATE ON "public"."games" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_giveaways_updated_at" BEFORE UPDATE ON "public"."giveaways" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_profiles_updated_at" BEFORE UPDATE ON "public"."profiles" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_site_settings_updated_at" BEFORE UPDATE ON "public"."site_settings" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_songs_updated_at" BEFORE UPDATE ON "public"."songs" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



ALTER TABLE ONLY "public"."colouring_pages"
    ADD CONSTRAINT "colouring_pages_category_id_fkey" FOREIGN KEY ("category_id") REFERENCES "public"."colouring_categories"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."games"
    ADD CONSTRAINT "games_category_id_fkey" FOREIGN KEY ("category_id") REFERENCES "public"."game_categories"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."song_tags"
    ADD CONSTRAINT "song_tags_song_id_fkey" FOREIGN KEY ("song_id") REFERENCES "public"."songs"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."song_tags"
    ADD CONSTRAINT "song_tags_tag_id_fkey" FOREIGN KEY ("tag_id") REFERENCES "public"."tags"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_roles"
    ADD CONSTRAINT "user_roles_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



CREATE POLICY "Admins can delete categories" ON "public"."colouring_categories" FOR DELETE USING ("public"."has_role"(( SELECT "auth"."uid"() AS "uid"), 'admin'::"public"."app_role"));



CREATE POLICY "Admins can delete colouring pages" ON "public"."colouring_pages" FOR DELETE USING ("public"."has_role"(( SELECT "auth"."uid"() AS "uid"), 'admin'::"public"."app_role"));



CREATE POLICY "Admins can delete game categories" ON "public"."game_categories" FOR DELETE USING ("public"."has_role"(( SELECT "auth"."uid"() AS "uid"), 'admin'::"public"."app_role"));



CREATE POLICY "Admins can delete games" ON "public"."games" FOR DELETE USING ("public"."has_role"(( SELECT "auth"."uid"() AS "uid"), 'admin'::"public"."app_role"));



CREATE POLICY "Admins can delete giveaways" ON "public"."giveaways" FOR DELETE USING ("public"."has_role"(( SELECT "auth"."uid"() AS "uid"), 'admin'::"public"."app_role"));



CREATE POLICY "Admins can delete song tags" ON "public"."song_tags" FOR DELETE USING ("public"."has_role"(( SELECT "auth"."uid"() AS "uid"), 'admin'::"public"."app_role"));



CREATE POLICY "Admins can delete songs" ON "public"."songs" FOR DELETE USING ("public"."has_role"(( SELECT "auth"."uid"() AS "uid"), 'admin'::"public"."app_role"));



CREATE POLICY "Admins can delete tags" ON "public"."tags" FOR DELETE USING ("public"."has_role"(( SELECT "auth"."uid"() AS "uid"), 'admin'::"public"."app_role"));



CREATE POLICY "Admins can insert categories" ON "public"."colouring_categories" FOR INSERT WITH CHECK ("public"."has_role"(( SELECT "auth"."uid"() AS "uid"), 'admin'::"public"."app_role"));



CREATE POLICY "Admins can insert colouring pages" ON "public"."colouring_pages" FOR INSERT WITH CHECK ("public"."has_role"(( SELECT "auth"."uid"() AS "uid"), 'admin'::"public"."app_role"));



CREATE POLICY "Admins can insert game categories" ON "public"."game_categories" FOR INSERT WITH CHECK ("public"."has_role"(( SELECT "auth"."uid"() AS "uid"), 'admin'::"public"."app_role"));



CREATE POLICY "Admins can insert games" ON "public"."games" FOR INSERT WITH CHECK ("public"."has_role"(( SELECT "auth"."uid"() AS "uid"), 'admin'::"public"."app_role"));



CREATE POLICY "Admins can insert giveaways" ON "public"."giveaways" FOR INSERT WITH CHECK ("public"."has_role"(( SELECT "auth"."uid"() AS "uid"), 'admin'::"public"."app_role"));



CREATE POLICY "Admins can insert profiles" ON "public"."profiles" FOR INSERT WITH CHECK ("public"."has_role"(( SELECT "auth"."uid"() AS "uid"), 'admin'::"public"."app_role"));



CREATE POLICY "Admins can insert site settings" ON "public"."site_settings" FOR INSERT WITH CHECK ("public"."has_role"(( SELECT "auth"."uid"() AS "uid"), 'admin'::"public"."app_role"));



CREATE POLICY "Admins can insert song tags" ON "public"."song_tags" FOR INSERT WITH CHECK ("public"."has_role"(( SELECT "auth"."uid"() AS "uid"), 'admin'::"public"."app_role"));



CREATE POLICY "Admins can insert songs" ON "public"."songs" FOR INSERT WITH CHECK ("public"."has_role"(( SELECT "auth"."uid"() AS "uid"), 'admin'::"public"."app_role"));



CREATE POLICY "Admins can insert tags" ON "public"."tags" FOR INSERT WITH CHECK ("public"."has_role"(( SELECT "auth"."uid"() AS "uid"), 'admin'::"public"."app_role"));



CREATE POLICY "Admins can update categories" ON "public"."colouring_categories" FOR UPDATE USING ("public"."has_role"(( SELECT "auth"."uid"() AS "uid"), 'admin'::"public"."app_role"));



CREATE POLICY "Admins can update colouring pages" ON "public"."colouring_pages" FOR UPDATE USING ("public"."has_role"(( SELECT "auth"."uid"() AS "uid"), 'admin'::"public"."app_role"));



CREATE POLICY "Admins can update game categories" ON "public"."game_categories" FOR UPDATE USING ("public"."has_role"(( SELECT "auth"."uid"() AS "uid"), 'admin'::"public"."app_role"));



CREATE POLICY "Admins can update games" ON "public"."games" FOR UPDATE USING ("public"."has_role"(( SELECT "auth"."uid"() AS "uid"), 'admin'::"public"."app_role"));



CREATE POLICY "Admins can update giveaways" ON "public"."giveaways" FOR UPDATE USING ("public"."has_role"(( SELECT "auth"."uid"() AS "uid"), 'admin'::"public"."app_role"));



CREATE POLICY "Admins can update profiles" ON "public"."profiles" FOR UPDATE USING ("public"."has_role"(( SELECT "auth"."uid"() AS "uid"), 'admin'::"public"."app_role"));



CREATE POLICY "Admins can update site settings" ON "public"."site_settings" FOR UPDATE USING ("public"."has_role"(( SELECT "auth"."uid"() AS "uid"), 'admin'::"public"."app_role"));



CREATE POLICY "Admins can update songs" ON "public"."songs" FOR UPDATE USING ("public"."has_role"(( SELECT "auth"."uid"() AS "uid"), 'admin'::"public"."app_role"));



CREATE POLICY "Admins can update tags" ON "public"."tags" FOR UPDATE USING ("public"."has_role"(( SELECT "auth"."uid"() AS "uid"), 'admin'::"public"."app_role"));



CREATE POLICY "Admins can view all profiles" ON "public"."profiles" FOR SELECT USING ("public"."has_role"(( SELECT "auth"."uid"() AS "uid"), 'admin'::"public"."app_role"));



CREATE POLICY "Anyone can submit contact form" ON "public"."contact_submissions" FOR INSERT WITH CHECK (true);



CREATE POLICY "Anyone can view categories" ON "public"."colouring_categories" FOR SELECT USING (true);



CREATE POLICY "Anyone can view colouring pages" ON "public"."colouring_pages" FOR SELECT USING (true);



CREATE POLICY "Anyone can view game categories" ON "public"."game_categories" FOR SELECT USING (true);



CREATE POLICY "Anyone can view games" ON "public"."games" FOR SELECT USING (true);



CREATE POLICY "Anyone can view giveaways" ON "public"."giveaways" FOR SELECT USING (true);



CREATE POLICY "Anyone can view site settings" ON "public"."site_settings" FOR SELECT USING (true);



CREATE POLICY "Anyone can view song tags" ON "public"."song_tags" FOR SELECT USING (true);



CREATE POLICY "Anyone can view songs" ON "public"."songs" FOR SELECT USING (true);



CREATE POLICY "Anyone can view tags" ON "public"."tags" FOR SELECT USING (true);



CREATE POLICY "Only admins can delete roles" ON "public"."user_roles" FOR DELETE USING ("public"."has_role"(( SELECT "auth"."uid"() AS "uid"), 'admin'::"public"."app_role"));



CREATE POLICY "Only admins can insert roles" ON "public"."user_roles" FOR INSERT WITH CHECK ("public"."has_role"(( SELECT "auth"."uid"() AS "uid"), 'admin'::"public"."app_role"));



CREATE POLICY "Only admins can update contact submissions" ON "public"."contact_submissions" FOR UPDATE USING ("public"."has_role"(( SELECT "auth"."uid"() AS "uid"), 'admin'::"public"."app_role"));



CREATE POLICY "Only admins can update roles" ON "public"."user_roles" FOR UPDATE USING ("public"."has_role"(( SELECT "auth"."uid"() AS "uid"), 'admin'::"public"."app_role"));



CREATE POLICY "Only admins can view contact submissions" ON "public"."contact_submissions" FOR SELECT USING ("public"."has_role"(( SELECT "auth"."uid"() AS "uid"), 'admin'::"public"."app_role"));



CREATE POLICY "Users can view own roles or admins can view all" ON "public"."user_roles" FOR SELECT USING (((( SELECT "auth"."uid"() AS "uid") = "user_id") OR "public"."has_role"(( SELECT "auth"."uid"() AS "uid"), 'admin'::"public"."app_role")));



ALTER TABLE "public"."colouring_categories" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."colouring_pages" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."contact_submissions" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."game_categories" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."games" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."giveaways" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."profiles" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."site_settings" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."song_tags" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."songs" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."tags" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."user_roles" ENABLE ROW LEVEL SECURITY;




ALTER PUBLICATION "supabase_realtime" OWNER TO "postgres";


GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";

























































































































































GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "service_role";



GRANT ALL ON FUNCTION "public"."has_role"("_user_id" "uuid", "_role" "public"."app_role") TO "anon";
GRANT ALL ON FUNCTION "public"."has_role"("_user_id" "uuid", "_role" "public"."app_role") TO "authenticated";
GRANT ALL ON FUNCTION "public"."has_role"("_user_id" "uuid", "_role" "public"."app_role") TO "service_role";



GRANT ALL ON FUNCTION "public"."update_updated_at_column"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_updated_at_column"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_updated_at_column"() TO "service_role";


















GRANT ALL ON TABLE "public"."colouring_categories" TO "anon";
GRANT ALL ON TABLE "public"."colouring_categories" TO "authenticated";
GRANT ALL ON TABLE "public"."colouring_categories" TO "service_role";



GRANT ALL ON TABLE "public"."colouring_pages" TO "anon";
GRANT ALL ON TABLE "public"."colouring_pages" TO "authenticated";
GRANT ALL ON TABLE "public"."colouring_pages" TO "service_role";



GRANT ALL ON TABLE "public"."contact_submissions" TO "anon";
GRANT ALL ON TABLE "public"."contact_submissions" TO "authenticated";
GRANT ALL ON TABLE "public"."contact_submissions" TO "service_role";



GRANT ALL ON TABLE "public"."game_categories" TO "anon";
GRANT ALL ON TABLE "public"."game_categories" TO "authenticated";
GRANT ALL ON TABLE "public"."game_categories" TO "service_role";



GRANT ALL ON TABLE "public"."games" TO "anon";
GRANT ALL ON TABLE "public"."games" TO "authenticated";
GRANT ALL ON TABLE "public"."games" TO "service_role";



GRANT ALL ON TABLE "public"."giveaways" TO "anon";
GRANT ALL ON TABLE "public"."giveaways" TO "authenticated";
GRANT ALL ON TABLE "public"."giveaways" TO "service_role";



GRANT ALL ON TABLE "public"."profiles" TO "anon";
GRANT ALL ON TABLE "public"."profiles" TO "authenticated";
GRANT ALL ON TABLE "public"."profiles" TO "service_role";



GRANT ALL ON TABLE "public"."site_settings" TO "anon";
GRANT ALL ON TABLE "public"."site_settings" TO "authenticated";
GRANT ALL ON TABLE "public"."site_settings" TO "service_role";



GRANT ALL ON TABLE "public"."song_tags" TO "anon";
GRANT ALL ON TABLE "public"."song_tags" TO "authenticated";
GRANT ALL ON TABLE "public"."song_tags" TO "service_role";



GRANT ALL ON TABLE "public"."songs" TO "anon";
GRANT ALL ON TABLE "public"."songs" TO "authenticated";
GRANT ALL ON TABLE "public"."songs" TO "service_role";



GRANT ALL ON TABLE "public"."tags" TO "anon";
GRANT ALL ON TABLE "public"."tags" TO "authenticated";
GRANT ALL ON TABLE "public"."tags" TO "service_role";



GRANT ALL ON TABLE "public"."user_roles" TO "anon";
GRANT ALL ON TABLE "public"."user_roles" TO "authenticated";
GRANT ALL ON TABLE "public"."user_roles" TO "service_role";









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































