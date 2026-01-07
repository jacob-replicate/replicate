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
-- Name: vector; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS vector WITH SCHEMA public;


--
-- Name: EXTENSION vector; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION vector IS 'vector data type and ivfflat and hnsw access methods';


SET default_tablespace = '';

SET default_table_access_method = heap;

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
-- Name: audits; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.audits (
    id bigint NOT NULL,
    auditable_id integer,
    auditable_type character varying,
    associated_id integer,
    associated_type character varying,
    user_id integer,
    user_type character varying,
    username character varying,
    action character varying,
    audited_changes text,
    version integer DEFAULT 0,
    comment character varying,
    remote_address character varying,
    request_uuid character varying,
    created_at timestamp(6) without time zone
);


--
-- Name: audits_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.audits_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: audits_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.audits_id_seq OWNED BY public.audits.id;


--
-- Name: banned_ips; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.banned_ips (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    address character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: cached_llm_responses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cached_llm_responses (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    template_name text,
    inputs jsonb,
    input_hash text,
    response jsonb,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: contacts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.contacts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    email text,
    location text,
    company_domain text,
    state text,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    source text,
    external_id text,
    score integer DEFAULT 0,
    score_reason text,
    metadata jsonb DEFAULT '{}'::jsonb,
    name text,
    cohort text,
    unsubscribed boolean DEFAULT false NOT NULL,
    email_queued_at timestamp(6) without time zone DEFAULT NULL::timestamp without time zone,
    contacted_at timestamp(6) without time zone
);


--
-- Name: conversations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.conversations (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    recipient_type character varying,
    recipient_id uuid,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    context jsonb DEFAULT '{}'::jsonb NOT NULL,
    channel character varying,
    subject_line text,
    sequence_count integer DEFAULT 0 NOT NULL,
    ip_address character varying,
    sharing_code character varying,
    referring_conversation_id uuid
);


--
-- Name: elements; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.elements (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    code text,
    context jsonb,
    experience_id uuid,
    element_id uuid,
    conversation_id uuid,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: experiences; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.experiences (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    template boolean,
    code text,
    name text,
    session_id text,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    description text
);


--
-- Name: members; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.members (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    organization_id character varying NOT NULL,
    name character varying,
    email character varying NOT NULL,
    role character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    email_domain character varying,
    subscribed boolean DEFAULT true NOT NULL,
    email_bounced boolean DEFAULT false NOT NULL
);


--
-- Name: messages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.messages (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    content text,
    conversation_id uuid,
    user_generated boolean,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    email_message_id_header text,
    suggested boolean DEFAULT false
);


--
-- Name: missive_webhooks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.missive_webhooks (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    webhook_type character varying,
    content json,
    processed_at timestamp(6) without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: organizations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.organizations (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    access_end_date timestamp(6) without time zone,
    flagged boolean DEFAULT false,
    flagged_reason text
);


--
-- Name: postmark_webhooks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.postmark_webhooks (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    webhook_type character varying,
    content json,
    conversation_id uuid,
    processed_at timestamp(6) without time zone,
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
-- Name: sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sessions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    ip character varying,
    page character varying,
    referring_page character varying,
    duration integer,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    user_agent text
);


--
-- Name: audits id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audits ALTER COLUMN id SET DEFAULT nextval('public.audits_id_seq'::regclass);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: audits audits_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audits
    ADD CONSTRAINT audits_pkey PRIMARY KEY (id);


--
-- Name: banned_ips banned_ips_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.banned_ips
    ADD CONSTRAINT banned_ips_pkey PRIMARY KEY (id);


--
-- Name: cached_llm_responses cached_llm_responses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cached_llm_responses
    ADD CONSTRAINT cached_llm_responses_pkey PRIMARY KEY (id);


--
-- Name: contacts contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contacts
    ADD CONSTRAINT contacts_pkey PRIMARY KEY (id);


--
-- Name: conversations conversations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.conversations
    ADD CONSTRAINT conversations_pkey PRIMARY KEY (id);


--
-- Name: elements elements_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.elements
    ADD CONSTRAINT elements_pkey PRIMARY KEY (id);


--
-- Name: experiences experiences_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.experiences
    ADD CONSTRAINT experiences_pkey PRIMARY KEY (id);


--
-- Name: members members_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.members
    ADD CONSTRAINT members_pkey PRIMARY KEY (id);


--
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id);


--
-- Name: missive_webhooks missive_webhooks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.missive_webhooks
    ADD CONSTRAINT missive_webhooks_pkey PRIMARY KEY (id);


--
-- Name: organizations organizations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organizations
    ADD CONSTRAINT organizations_pkey PRIMARY KEY (id);


--
-- Name: postmark_webhooks postmark_webhooks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.postmark_webhooks
    ADD CONSTRAINT postmark_webhooks_pkey PRIMARY KEY (id);


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
-- Name: associated_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX associated_index ON public.audits USING btree (associated_type, associated_id);


--
-- Name: auditable_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX auditable_index ON public.audits USING btree (auditable_type, auditable_id, version);


--
-- Name: index_audits_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_audits_on_created_at ON public.audits USING btree (created_at);


--
-- Name: index_audits_on_request_uuid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_audits_on_request_uuid ON public.audits USING btree (request_uuid);


--
-- Name: index_cached_llm_on_template_and_input_hash; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cached_llm_on_template_and_input_hash ON public.cached_llm_responses USING btree (template_name, input_hash);


--
-- Name: index_conversations_on_recipient; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_conversations_on_recipient ON public.conversations USING btree (recipient_type, recipient_id);


--
-- Name: index_conversations_on_referring_conversation_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_conversations_on_referring_conversation_id ON public.conversations USING btree (referring_conversation_id);


--
-- Name: index_conversations_on_sharing_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_conversations_on_sharing_code ON public.conversations USING btree (sharing_code);


--
-- Name: index_elements_on_conversation_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_elements_on_conversation_id ON public.elements USING btree (conversation_id);


--
-- Name: index_elements_on_element_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_elements_on_element_id ON public.elements USING btree (element_id);


--
-- Name: index_elements_on_experience_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_elements_on_experience_id ON public.elements USING btree (experience_id);


--
-- Name: index_members_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_members_on_organization_id ON public.members USING btree (organization_id);


--
-- Name: index_members_on_organization_id_and_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_members_on_organization_id_and_email ON public.members USING btree (organization_id, email);


--
-- Name: index_messages_on_conversation_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_messages_on_conversation_id ON public.messages USING btree (conversation_id);


--
-- Name: user_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_index ON public.audits USING btree (user_id, user_type);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20260107042958'),
('20260105031841'),
('20260105025819'),
('20251125184913'),
('20251125181409'),
('20251108011957'),
('20251105045745'),
('20251105040503'),
('20251105012750'),
('20251022074354'),
('20251018193053'),
('20251018183734'),
('20251018175339'),
('20251018163154'),
('20250930004845'),
('20250930002309'),
('20250929235307'),
('20250923013123'),
('20250918025026'),
('20250912005642'),
('20250912005635'),
('20250907015905'),
('20250906162252'),
('20250905012419'),
('20250905012103'),
('20250904212124'),
('20250903180922'),
('20250902160824'),
('20250824030354'),
('20250819001348'),
('20250819000806'),
('20250819000641'),
('20250818015702'),
('20250818014440'),
('20250818012646'),
('20250816212502'),
('20250813215753'),
('20250813215707'),
('20250813215545'),
('20250809174803'),
('20250727223433'),
('20250719171253'),
('20250719161016'),
('20250718033219'),
('20250716033556'),
('20250711035414'),
('20250711035405'),
('20250701232603'),
('20250701232143'),
('20250627002421'),
('20250626230505'),
('20250625045130'),
('20250622182901');

