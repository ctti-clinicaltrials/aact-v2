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
-- Name: ctgov_api; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA ctgov_api;


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
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: aact_mappings id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.aact_mappings ALTER COLUMN id SET DEFAULT nextval('ctgov.aact_mappings_id_seq'::regclass);


--
-- Name: api_metadata id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.api_metadata ALTER COLUMN id SET DEFAULT nextval('ctgov.api_metadata_id_seq'::regclass);


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
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: index_aact_mappings_on_api_metadata_id; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_aact_mappings_on_api_metadata_id ON ctgov.aact_mappings USING btree (api_metadata_id);


--
-- Name: index_aact_mappings_on_table_field_api_path; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE UNIQUE INDEX index_aact_mappings_on_table_field_api_path ON ctgov.aact_mappings USING btree (table_name, field_name, api_path);


--
-- Name: aact_mappings fk_rails_a68c0de943; Type: FK CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.aact_mappings
    ADD CONSTRAINT fk_rails_a68c0de943 FOREIGN KEY (api_metadata_id) REFERENCES ctgov.api_metadata(id) ON DELETE SET NULL;


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20241013183335'),
('20241004010026'),
('20241003191112');

