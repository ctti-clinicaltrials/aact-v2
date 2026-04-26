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

--
-- Name: ctgov; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA ctgov;


--
-- Name: snapshots; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA snapshots;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: aact_public_query_metrics; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.aact_public_query_metrics (
    id bigint NOT NULL,
    log_date date NOT NULL,
    username character varying NOT NULL,
    query_count integer DEFAULT 0 NOT NULL,
    total_duration_ms double precision DEFAULT 0.0 NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: aact_public_query_metrics_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.aact_public_query_metrics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: aact_public_query_metrics_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.aact_public_query_metrics_id_seq OWNED BY public.aact_public_query_metrics.id;


--
-- Name: analytics_snapshot_downloads; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.analytics_snapshot_downloads (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    file_type character varying NOT NULL,
    snapshot_id character varying NOT NULL,
    ip_address character varying,
    user_agent character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    source character varying DEFAULT 'web'::character varying NOT NULL
);


--
-- Name: analytics_snapshot_downloads_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.analytics_snapshot_downloads_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: analytics_snapshot_downloads_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.analytics_snapshot_downloads_id_seq OWNED BY public.analytics_snapshot_downloads.id;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: ctgov_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ctgov_metadata (
    id bigint NOT NULL,
    path character varying NOT NULL,
    name character varying NOT NULL,
    piece character varying,
    title character varying,
    source_type character varying NOT NULL,
    type character varying,
    is_enum boolean,
    max_chars integer,
    description text,
    rules text,
    synonyms boolean,
    alt_piece_names text[] DEFAULT '{}'::text[],
    ded_link_label character varying,
    ded_link_url text,
    active boolean DEFAULT true NOT NULL,
    api_version character varying DEFAULT '2'::character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: ctgov_metadata_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ctgov_metadata_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ctgov_metadata_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ctgov_metadata_id_seq OWNED BY public.ctgov_metadata.id;


--
-- Name: documentation_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.documentation_items (
    id bigint NOT NULL,
    active boolean DEFAULT true,
    table_name character varying NOT NULL,
    column_name character varying NOT NULL,
    data_type character varying,
    nullable boolean,
    description text,
    ctgov_name character varying,
    ctgov_label character varying,
    ctgov_path character varying,
    ctgov_section character varying,
    ctgov_module character varying,
    ctgov_url character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: documentation_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.documentation_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: documentation_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.documentation_items_id_seq OWNED BY public.documentation_items.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sessions (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    ip_address character varying,
    user_agent character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: sessions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sessions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sessions_id_seq OWNED BY public.sessions.id;


--
-- Name: solid_cable_messages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.solid_cable_messages (
    id bigint NOT NULL,
    channel bytea NOT NULL,
    payload bytea NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    channel_hash bigint NOT NULL
);


--
-- Name: solid_cable_messages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.solid_cable_messages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: solid_cable_messages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.solid_cable_messages_id_seq OWNED BY public.solid_cable_messages.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    email_address character varying NOT NULL,
    password_digest character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    name character varying NOT NULL,
    admin boolean DEFAULT false NOT NULL,
    database_username character varying,
    database_password character varying,
    database_creation_status character varying DEFAULT 'not_requested'::character varying NOT NULL,
    database_creation_error text,
    database_creation_attempted_at timestamp(6) without time zone,
    migrated boolean DEFAULT false NOT NULL,
    metadata jsonb,
    first_name character varying(50),
    last_name character varying(50)
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: ctgov_metadata; Type: TABLE; Schema: snapshots; Owner: -
--

CREATE TABLE snapshots.ctgov_metadata (
    id bigint NOT NULL,
    api_version character varying DEFAULT '2'::character varying NOT NULL,
    snapshot jsonb NOT NULL,
    field_count integer,
    checksum text,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: ctgov_metadata_id_seq; Type: SEQUENCE; Schema: snapshots; Owner: -
--

CREATE SEQUENCE snapshots.ctgov_metadata_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ctgov_metadata_id_seq; Type: SEQUENCE OWNED BY; Schema: snapshots; Owner: -
--

ALTER SEQUENCE snapshots.ctgov_metadata_id_seq OWNED BY snapshots.ctgov_metadata.id;


--
-- Name: aact_public_query_metrics id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.aact_public_query_metrics ALTER COLUMN id SET DEFAULT nextval('public.aact_public_query_metrics_id_seq'::regclass);


--
-- Name: analytics_snapshot_downloads id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.analytics_snapshot_downloads ALTER COLUMN id SET DEFAULT nextval('public.analytics_snapshot_downloads_id_seq'::regclass);


--
-- Name: ctgov_metadata id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ctgov_metadata ALTER COLUMN id SET DEFAULT nextval('public.ctgov_metadata_id_seq'::regclass);


--
-- Name: documentation_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.documentation_items ALTER COLUMN id SET DEFAULT nextval('public.documentation_items_id_seq'::regclass);


--
-- Name: sessions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sessions ALTER COLUMN id SET DEFAULT nextval('public.sessions_id_seq'::regclass);


--
-- Name: solid_cable_messages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.solid_cable_messages ALTER COLUMN id SET DEFAULT nextval('public.solid_cable_messages_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: ctgov_metadata id; Type: DEFAULT; Schema: snapshots; Owner: -
--

ALTER TABLE ONLY snapshots.ctgov_metadata ALTER COLUMN id SET DEFAULT nextval('snapshots.ctgov_metadata_id_seq'::regclass);


--
-- Name: aact_public_query_metrics aact_public_query_metrics_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.aact_public_query_metrics
    ADD CONSTRAINT aact_public_query_metrics_pkey PRIMARY KEY (id);


--
-- Name: analytics_snapshot_downloads analytics_snapshot_downloads_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.analytics_snapshot_downloads
    ADD CONSTRAINT analytics_snapshot_downloads_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: ctgov_metadata ctgov_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ctgov_metadata
    ADD CONSTRAINT ctgov_metadata_pkey PRIMARY KEY (id);


--
-- Name: documentation_items documentation_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.documentation_items
    ADD CONSTRAINT documentation_items_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: solid_cable_messages solid_cable_messages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.solid_cable_messages
    ADD CONSTRAINT solid_cable_messages_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: ctgov_metadata ctgov_metadata_pkey; Type: CONSTRAINT; Schema: snapshots; Owner: -
--

ALTER TABLE ONLY snapshots.ctgov_metadata
    ADD CONSTRAINT ctgov_metadata_pkey PRIMARY KEY (id);


--
-- Name: index_aact_public_query_metrics_on_log_date_and_username; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_aact_public_query_metrics_on_log_date_and_username ON public.aact_public_query_metrics USING btree (log_date, username);


--
-- Name: index_analytics_snapshot_downloads_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_analytics_snapshot_downloads_on_created_at ON public.analytics_snapshot_downloads USING btree (created_at);


--
-- Name: index_analytics_snapshot_downloads_on_file_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_analytics_snapshot_downloads_on_file_type ON public.analytics_snapshot_downloads USING btree (file_type);


--
-- Name: index_analytics_snapshot_downloads_on_source; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_analytics_snapshot_downloads_on_source ON public.analytics_snapshot_downloads USING btree (source);


--
-- Name: index_analytics_snapshot_downloads_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_analytics_snapshot_downloads_on_user_id ON public.analytics_snapshot_downloads USING btree (user_id);


--
-- Name: index_ctgov_metadata_on_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ctgov_metadata_on_active ON public.ctgov_metadata USING btree (active);


--
-- Name: index_ctgov_metadata_on_alt_piece_names; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ctgov_metadata_on_alt_piece_names ON public.ctgov_metadata USING gin (alt_piece_names);


--
-- Name: index_ctgov_metadata_on_api_version; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ctgov_metadata_on_api_version ON public.ctgov_metadata USING btree (api_version);


--
-- Name: index_ctgov_metadata_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ctgov_metadata_on_name ON public.ctgov_metadata USING btree (name);


--
-- Name: index_ctgov_metadata_on_path; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_ctgov_metadata_on_path ON public.ctgov_metadata USING btree (path);


--
-- Name: index_ctgov_metadata_on_source_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ctgov_metadata_on_source_type ON public.ctgov_metadata USING btree (source_type);


--
-- Name: index_documentation_items_on_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_documentation_items_on_active ON public.documentation_items USING btree (active);


--
-- Name: index_documentation_items_on_table_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_documentation_items_on_table_name ON public.documentation_items USING btree (table_name);


--
-- Name: index_documentation_items_on_table_name_and_column_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_documentation_items_on_table_name_and_column_name ON public.documentation_items USING btree (table_name, column_name);


--
-- Name: index_sessions_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sessions_on_user_id ON public.sessions USING btree (user_id);


--
-- Name: index_solid_cable_messages_on_channel; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_solid_cable_messages_on_channel ON public.solid_cable_messages USING btree (channel);


--
-- Name: index_solid_cable_messages_on_channel_hash; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_solid_cable_messages_on_channel_hash ON public.solid_cable_messages USING btree (channel_hash);


--
-- Name: index_solid_cable_messages_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_solid_cable_messages_on_created_at ON public.solid_cable_messages USING btree (created_at);


--
-- Name: index_users_on_database_creation_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_database_creation_status ON public.users USING btree (database_creation_status);


--
-- Name: index_users_on_database_username; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_database_username ON public.users USING btree (database_username);


--
-- Name: index_users_on_email_address; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email_address ON public.users USING btree (email_address);


--
-- Name: index_ctgov_metadata_on_api_version; Type: INDEX; Schema: snapshots; Owner: -
--

CREATE INDEX index_ctgov_metadata_on_api_version ON snapshots.ctgov_metadata USING btree (api_version);


--
-- Name: index_ctgov_metadata_on_checksum; Type: INDEX; Schema: snapshots; Owner: -
--

CREATE INDEX index_ctgov_metadata_on_checksum ON snapshots.ctgov_metadata USING btree (checksum);


--
-- Name: index_ctgov_metadata_on_created_at; Type: INDEX; Schema: snapshots; Owner: -
--

CREATE INDEX index_ctgov_metadata_on_created_at ON snapshots.ctgov_metadata USING btree (created_at);


--
-- Name: analytics_snapshot_downloads fk_rails_22fa5bbe06; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.analytics_snapshot_downloads
    ADD CONSTRAINT fk_rails_22fa5bbe06 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: sessions fk_rails_758836b4f0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT fk_rails_758836b4f0 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20260425231615'),
('20260327210756'),
('20260327015820'),
('20260219151943'),
('20260215120000'),
('20251209120000'),
('20251126135835'),
('20251028004756'),
('20251007131403'),
('20251001002824'),
('20251001002823'),
('20250930134454'),
('20250930134453'),
('20250930134452'),
('20250601000000'),
('20241013183335'),
('20241004010026'),
('20241003191112'),
('1');

