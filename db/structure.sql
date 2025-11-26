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


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: aact_mappings; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.aact_mappings (
    id bigint NOT NULL,
    table_name character varying,
    field_name character varying,
    active boolean DEFAULT true,
    api_path character varying,
    api_metadata_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: aact_mappings_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.aact_mappings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: aact_mappings_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.aact_mappings_id_seq OWNED BY ctgov.aact_mappings.id;


--
-- Name: api_metadata; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.api_metadata (
    id bigint NOT NULL,
    version character varying,
    name character varying,
    data_type character varying,
    piece character varying,
    source_type character varying,
    synonyms boolean,
    label character varying,
    url character varying,
    section character varying,
    module character varying,
    path character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: api_metadata_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.api_metadata_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: api_metadata_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.api_metadata_id_seq OWNED BY ctgov.api_metadata.id;


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
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


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
    name character varying,
    admin boolean DEFAULT false NOT NULL,
    database_username character varying,
    database_password character varying,
    database_creation_status character varying DEFAULT 'not_requested'::character varying NOT NULL,
    database_creation_error text,
    database_creation_attempted_at timestamp(6) without time zone
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
-- Name: aact_mappings id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.aact_mappings ALTER COLUMN id SET DEFAULT nextval('ctgov.aact_mappings_id_seq'::regclass);


--
-- Name: api_metadata id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.api_metadata ALTER COLUMN id SET DEFAULT nextval('ctgov.api_metadata_id_seq'::regclass);


--
-- Name: aact_public_query_metrics id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.aact_public_query_metrics ALTER COLUMN id SET DEFAULT nextval('public.aact_public_query_metrics_id_seq'::regclass);


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
-- Name: aact_mappings aact_mappings_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.aact_mappings
    ADD CONSTRAINT aact_mappings_pkey PRIMARY KEY (id);


--
-- Name: api_metadata api_metadata_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.api_metadata
    ADD CONSTRAINT api_metadata_pkey PRIMARY KEY (id);


--
-- Name: aact_public_query_metrics aact_public_query_metrics_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.aact_public_query_metrics
    ADD CONSTRAINT aact_public_query_metrics_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


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
-- Name: index_aact_mappings_on_api_metadata_id; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_aact_mappings_on_api_metadata_id ON ctgov.aact_mappings USING btree (api_metadata_id);


--
-- Name: index_aact_mappings_on_table_field_api_path; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE UNIQUE INDEX index_aact_mappings_on_table_field_api_path ON ctgov.aact_mappings USING btree (table_name, field_name, api_path);


--
-- Name: index_aact_public_query_metrics_on_log_date_and_username; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_aact_public_query_metrics_on_log_date_and_username ON public.aact_public_query_metrics USING btree (log_date, username);


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
-- Name: index_users_on_email_address; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email_address ON public.users USING btree (email_address);


--
-- Name: aact_mappings fk_rails_a68c0de943; Type: FK CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.aact_mappings
    ADD CONSTRAINT fk_rails_a68c0de943 FOREIGN KEY (api_metadata_id) REFERENCES ctgov.api_metadata(id) ON DELETE SET NULL;


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

