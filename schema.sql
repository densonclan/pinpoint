--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

--
-- Name: plpgsql; Type: PROCEDURAL LANGUAGE; Schema: -; Owner: postgres
--

CREATE OR REPLACE PROCEDURAL LANGUAGE plpgsql;


ALTER PROCEDURAL LANGUAGE plpgsql OWNER TO postgres;

SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: addresses; Type: TABLE; Schema: public; Owner: pinpoint; Tablespace: 
--

CREATE TABLE addresses (
    id integer NOT NULL,
    title character varying(4) DEFAULT ''::character varying NOT NULL,
    full_name character varying(255),
    first_line character varying(255),
    second_line character varying(255),
    third_line character varying(255),
    city character varying(255),
    postcode character varying(255),
    county character varying(255),
    phone_number character varying(255) DEFAULT '0'::character varying,
    email character varying(255),
    address_type character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    business_name character varying(255),
    store_id integer
);


ALTER TABLE public.addresses OWNER TO pinpoint;

--
-- Name: addresses_id_seq; Type: SEQUENCE; Schema: public; Owner: pinpoint
--

CREATE SEQUENCE addresses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.addresses_id_seq OWNER TO pinpoint;

--
-- Name: addresses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pinpoint
--

ALTER SEQUENCE addresses_id_seq OWNED BY addresses.id;


--
-- Name: business_managers; Type: TABLE; Schema: public; Owner: pinpoint; Tablespace: 
--

CREATE TABLE business_managers (
    id integer NOT NULL,
    name character varying(255),
    email character varying(255),
    additional_info text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    client_id integer,
    phone_number character varying(255)
);


ALTER TABLE public.business_managers OWNER TO pinpoint;

--
-- Name: business_managers_id_seq; Type: SEQUENCE; Schema: public; Owner: pinpoint
--

CREATE SEQUENCE business_managers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.business_managers_id_seq OWNER TO pinpoint;

--
-- Name: business_managers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pinpoint
--

ALTER SEQUENCE business_managers_id_seq OWNED BY business_managers.id;


--
-- Name: clients; Type: TABLE; Schema: public; Owner: pinpoint; Tablespace: 
--

CREATE TABLE clients (
    id integer NOT NULL,
    name character varying(255),
    description text,
    code character varying(255),
    reference character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.clients OWNER TO pinpoint;

--
-- Name: clients_id_seq; Type: SEQUENCE; Schema: public; Owner: pinpoint
--

CREATE SEQUENCE clients_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.clients_id_seq OWNER TO pinpoint;

--
-- Name: clients_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pinpoint
--

ALTER SEQUENCE clients_id_seq OWNED BY clients.id;


--
-- Name: comments; Type: TABLE; Schema: public; Owner: pinpoint; Tablespace: 
--

CREATE TABLE comments (
    id integer NOT NULL,
    full_text text,
    user_id integer,
    commentable_id integer,
    commentable_type character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.comments OWNER TO pinpoint;

--
-- Name: comments_id_seq; Type: SEQUENCE; Schema: public; Owner: pinpoint
--

CREATE SEQUENCE comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.comments_id_seq OWNER TO pinpoint;

--
-- Name: comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pinpoint
--

ALTER SEQUENCE comments_id_seq OWNED BY comments.id;


--
-- Name: departments; Type: TABLE; Schema: public; Owner: pinpoint; Tablespace: 
--

CREATE TABLE departments (
    id integer NOT NULL,
    name character varying(255),
    short_code character varying(255),
    description character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.departments OWNER TO pinpoint;

--
-- Name: departments_id_seq; Type: SEQUENCE; Schema: public; Owner: pinpoint
--

CREATE SEQUENCE departments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.departments_id_seq OWNER TO pinpoint;

--
-- Name: departments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pinpoint
--

ALTER SEQUENCE departments_id_seq OWNED BY departments.id;


--
-- Name: distribution_postcodes; Type: TABLE; Schema: public; Owner: pinpoint; Tablespace: 
--

CREATE TABLE distribution_postcodes (
    id integer NOT NULL,
    distribution_id integer,
    postcode_sector_id integer
);


ALTER TABLE public.distribution_postcodes OWNER TO pinpoint;

--
-- Name: distribution_postcodes_id_seq; Type: SEQUENCE; Schema: public; Owner: pinpoint
--

CREATE SEQUENCE distribution_postcodes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.distribution_postcodes_id_seq OWNER TO pinpoint;

--
-- Name: distribution_postcodes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pinpoint
--

ALTER SEQUENCE distribution_postcodes_id_seq OWNED BY distribution_postcodes.id;


--
-- Name: distributions; Type: TABLE; Schema: public; Owner: pinpoint; Tablespace: 
--

CREATE TABLE distributions (
    id integer NOT NULL,
    total_quantity integer,
    total_boxes integer,
    description character varying(255),
    contract_number character varying(255),
    reference_number character varying(255),
    order_id integer,
    distributor_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    updated_by_id integer,
    distribution_week integer NOT NULL,
    ship_via character varying(255)
);


ALTER TABLE public.distributions OWNER TO pinpoint;

--
-- Name: distributions_id_seq; Type: SEQUENCE; Schema: public; Owner: pinpoint
--

CREATE SEQUENCE distributions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.distributions_id_seq OWNER TO pinpoint;

--
-- Name: distributions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pinpoint
--

ALTER SEQUENCE distributions_id_seq OWNED BY distributions.id;


--
-- Name: distributors; Type: TABLE; Schema: public; Owner: pinpoint; Tablespace: 
--

CREATE TABLE distributors (
    id integer NOT NULL,
    name character varying(255),
    distributor_type character varying(255),
    description text,
    reference_number character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.distributors OWNER TO pinpoint;

--
-- Name: distributors_id_seq; Type: SEQUENCE; Schema: public; Owner: pinpoint
--

CREATE SEQUENCE distributors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.distributors_id_seq OWNER TO pinpoint;

--
-- Name: distributors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pinpoint
--

ALTER SEQUENCE distributors_id_seq OWNED BY distributors.id;


--
-- Name: documents; Type: TABLE; Schema: public; Owner: pinpoint; Tablespace: 
--

CREATE TABLE documents (
    id integer NOT NULL,
    title character varying(255),
    description text,
    user_id integer,
    store_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    file_file_name character varying(255),
    file_content_type character varying(255),
    file_file_size integer,
    file_updated_at timestamp without time zone,
    document_type character varying(255)
);


ALTER TABLE public.documents OWNER TO pinpoint;

--
-- Name: documents_id_seq; Type: SEQUENCE; Schema: public; Owner: pinpoint
--

CREATE SEQUENCE documents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.documents_id_seq OWNER TO pinpoint;

--
-- Name: documents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pinpoint
--

ALTER SEQUENCE documents_id_seq OWNED BY documents.id;


--
-- Name: export_templates; Type: TABLE; Schema: public; Owner: pinpoint; Tablespace: 
--

CREATE TABLE export_templates (
    id integer NOT NULL,
    name character varying(255),
    value text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.export_templates OWNER TO pinpoint;

--
-- Name: export_templates_id_seq; Type: SEQUENCE; Schema: public; Owner: pinpoint
--

CREATE SEQUENCE export_templates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.export_templates_id_seq OWNER TO pinpoint;

--
-- Name: export_templates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pinpoint
--

ALTER SEQUENCE export_templates_id_seq OWNED BY export_templates.id;


--
-- Name: logotypes; Type: TABLE; Schema: public; Owner: pinpoint; Tablespace: 
--

CREATE TABLE logotypes (
    id integer NOT NULL,
    title character varying(255),
    reference_number character varying(255),
    file_path character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    image_file_name character varying(255),
    image_content_type character varying(255),
    image_file_size integer,
    image_updated_at timestamp without time zone,
    updated_by_id integer
);


ALTER TABLE public.logotypes OWNER TO pinpoint;

--
-- Name: logotypes_id_seq; Type: SEQUENCE; Schema: public; Owner: pinpoint
--

CREATE SEQUENCE logotypes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.logotypes_id_seq OWNER TO pinpoint;

--
-- Name: logotypes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pinpoint
--

ALTER SEQUENCE logotypes_id_seq OWNED BY logotypes.id;


--
-- Name: messages; Type: TABLE; Schema: public; Owner: pinpoint; Tablespace: 
--

CREATE TABLE messages (
    id integer NOT NULL,
    full_text character varying(255),
    subject character varying(255),
    user_id integer,
    receiver_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    read boolean DEFAULT false NOT NULL,
    read_at timestamp without time zone,
    archived boolean DEFAULT false NOT NULL
);


ALTER TABLE public.messages OWNER TO pinpoint;

--
-- Name: messages_id_seq; Type: SEQUENCE; Schema: public; Owner: pinpoint
--

CREATE SEQUENCE messages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.messages_id_seq OWNER TO pinpoint;

--
-- Name: messages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pinpoint
--

ALTER SEQUENCE messages_id_seq OWNED BY messages.id;


--
-- Name: option_values; Type: TABLE; Schema: public; Owner: pinpoint; Tablespace: 
--

CREATE TABLE option_values (
    id integer NOT NULL,
    period_id integer,
    option_id integer,
    page_id integer
);


ALTER TABLE public.option_values OWNER TO pinpoint;

--
-- Name: option_values_id_seq; Type: SEQUENCE; Schema: public; Owner: pinpoint
--

CREATE SEQUENCE option_values_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.option_values_id_seq OWNER TO pinpoint;

--
-- Name: option_values_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pinpoint
--

ALTER SEQUENCE option_values_id_seq OWNED BY option_values.id;


--
-- Name: options; Type: TABLE; Schema: public; Owner: pinpoint; Tablespace: 
--

CREATE TABLE options (
    id integer NOT NULL,
    name character varying(255),
    description character varying(255),
    price_zone character varying(255),
    multibuy boolean,
    licenced boolean,
    total_ambient integer DEFAULT 0,
    total_licenced integer DEFAULT 0,
    total_temp integer DEFAULT 0,
    total_quantity integer DEFAULT 0,
    reference_number character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    client_id integer
);


ALTER TABLE public.options OWNER TO pinpoint;

--
-- Name: options_id_seq; Type: SEQUENCE; Schema: public; Owner: pinpoint
--

CREATE SEQUENCE options_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.options_id_seq OWNER TO pinpoint;

--
-- Name: options_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pinpoint
--

ALTER SEQUENCE options_id_seq OWNED BY options.id;


--
-- Name: orders; Type: TABLE; Schema: public; Owner: pinpoint; Tablespace: 
--

CREATE TABLE orders (
    id integer NOT NULL,
    total_quantity integer DEFAULT 0,
    total_price integer DEFAULT 0,
    distribution_week integer DEFAULT 0,
    status integer DEFAULT 0 NOT NULL,
    user_id integer,
    store_id integer,
    period_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    option_id integer,
    updated_by_id integer,
    total_boxes integer
);


ALTER TABLE public.orders OWNER TO pinpoint;

--
-- Name: orders_id_seq; Type: SEQUENCE; Schema: public; Owner: pinpoint
--

CREATE SEQUENCE orders_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.orders_id_seq OWNER TO pinpoint;

--
-- Name: orders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pinpoint
--

ALTER SEQUENCE orders_id_seq OWNED BY orders.id;


--
-- Name: pages; Type: TABLE; Schema: public; Owner: pinpoint; Tablespace: 
--

CREATE TABLE pages (
    id integer NOT NULL,
    name character varying(255),
    description character varying(255),
    reference_number character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    box_quantity integer
);


ALTER TABLE public.pages OWNER TO pinpoint;

--
-- Name: pages_id_seq; Type: SEQUENCE; Schema: public; Owner: pinpoint
--

CREATE SEQUENCE pages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.pages_id_seq OWNER TO pinpoint;

--
-- Name: pages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pinpoint
--

ALTER SEQUENCE pages_id_seq OWNED BY pages.id;


--
-- Name: periods; Type: TABLE; Schema: public; Owner: pinpoint; Tablespace: 
--

CREATE TABLE periods (
    id integer NOT NULL,
    period_number integer DEFAULT 0,
    week_number integer DEFAULT 0,
    date_promo date,
    date_samples date,
    date_approval date,
    date_print date,
    date_dispatch date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    current boolean DEFAULT false,
    completed boolean DEFAULT false NOT NULL,
    date_promo_end date,
    client_id integer
);


ALTER TABLE public.periods OWNER TO pinpoint;

--
-- Name: periods_id_seq; Type: SEQUENCE; Schema: public; Owner: pinpoint
--

CREATE SEQUENCE periods_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.periods_id_seq OWNER TO pinpoint;

--
-- Name: periods_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pinpoint
--

ALTER SEQUENCE periods_id_seq OWNED BY periods.id;


--
-- Name: postcode_sectors; Type: TABLE; Schema: public; Owner: pinpoint; Tablespace: 
--

CREATE TABLE postcode_sectors (
    id integer NOT NULL,
    area character varying(2),
    district integer,
    sector integer,
    residential integer,
    business integer,
    zone character varying(2),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.postcode_sectors OWNER TO pinpoint;

--
-- Name: postcode_sectors_id_seq; Type: SEQUENCE; Schema: public; Owner: pinpoint
--

CREATE SEQUENCE postcode_sectors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.postcode_sectors_id_seq OWNER TO pinpoint;

--
-- Name: postcode_sectors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pinpoint
--

ALTER SEQUENCE postcode_sectors_id_seq OWNED BY postcode_sectors.id;


--
-- Name: record_locks; Type: TABLE; Schema: public; Owner: pinpoint; Tablespace: 
--

CREATE TABLE record_locks (
    id integer NOT NULL,
    record_type character varying(255),
    record_id integer,
    user_id integer,
    created_at timestamp without time zone
);


ALTER TABLE public.record_locks OWNER TO pinpoint;

--
-- Name: record_locks_id_seq; Type: SEQUENCE; Schema: public; Owner: pinpoint
--

CREATE SEQUENCE record_locks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.record_locks_id_seq OWNER TO pinpoint;

--
-- Name: record_locks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pinpoint
--

ALTER SEQUENCE record_locks_id_seq OWNED BY record_locks.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: pinpoint; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


ALTER TABLE public.schema_migrations OWNER TO pinpoint;

--
-- Name: stores; Type: TABLE; Schema: public; Owner: pinpoint; Tablespace: 
--

CREATE TABLE stores (
    id integer NOT NULL,
    account_number character varying(255),
    reference_number character varying(255),
    owner_name character varying(255),
    description text,
    postcode character varying(255),
    preferred_distribution character varying(255) DEFAULT ''::character varying NOT NULL,
    client_id integer,
    logotype_id integer,
    business_manager_id integer,
    user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    updated_by_id integer,
    logo character varying(255),
    store_urgent boolean
);


ALTER TABLE public.stores OWNER TO pinpoint;

--
-- Name: stores_id_seq; Type: SEQUENCE; Schema: public; Owner: pinpoint
--

CREATE SEQUENCE stores_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.stores_id_seq OWNER TO pinpoint;

--
-- Name: stores_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pinpoint
--

ALTER SEQUENCE stores_id_seq OWNED BY stores.id;


--
-- Name: tasks; Type: TABLE; Schema: public; Owner: pinpoint; Tablespace: 
--

CREATE TABLE tasks (
    id integer NOT NULL,
    full_text character varying(255),
    completed boolean,
    completion integer DEFAULT 0,
    priority integer DEFAULT 0,
    agent_id integer,
    department_id integer,
    user_id integer,
    store_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    due_date date,
    archived boolean DEFAULT false,
    archived_at timestamp without time zone,
    for_department boolean DEFAULT false NOT NULL
);


ALTER TABLE public.tasks OWNER TO pinpoint;

--
-- Name: tasks_id_seq; Type: SEQUENCE; Schema: public; Owner: pinpoint
--

CREATE SEQUENCE tasks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tasks_id_seq OWNER TO pinpoint;

--
-- Name: tasks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pinpoint
--

ALTER SEQUENCE tasks_id_seq OWNED BY tasks.id;


--
-- Name: transports; Type: TABLE; Schema: public; Owner: pinpoint; Tablespace: 
--

CREATE TABLE transports (
    id integer NOT NULL,
    transport_type character varying(255),
    spreadsheet_file_name character varying(255),
    user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    status integer
);


ALTER TABLE public.transports OWNER TO pinpoint;

--
-- Name: transports_id_seq; Type: SEQUENCE; Schema: public; Owner: pinpoint
--

CREATE SEQUENCE transports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.transports_id_seq OWNER TO pinpoint;

--
-- Name: transports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pinpoint
--

ALTER SEQUENCE transports_id_seq OWNED BY transports.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: pinpoint; Tablespace: 
--

CREATE TABLE users (
    id integer NOT NULL,
    email character varying(255) DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying(255) DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying(255),
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip character varying(255),
    last_sign_in_ip character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    name character varying(255),
    phone character varying(255) DEFAULT NULL::character varying,
    department_id integer,
    approved boolean DEFAULT false NOT NULL,
    last_request_at timestamp without time zone,
    last_request character varying(255),
    avatar_file_name character varying(255),
    avatar_content_type character varying(255),
    avatar_file_size integer,
    avatar_updated_at timestamp without time zone,
    user_type integer,
    client_id integer
);


ALTER TABLE public.users OWNER TO pinpoint;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: pinpoint
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.users_id_seq OWNER TO pinpoint;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pinpoint
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: versions; Type: TABLE; Schema: public; Owner: pinpoint; Tablespace: 
--

CREATE TABLE versions (
    id integer NOT NULL,
    item_type character varying(255) NOT NULL,
    item_id integer NOT NULL,
    event character varying(255) NOT NULL,
    whodunnit character varying(255),
    object text,
    created_at timestamp without time zone,
    object_changes text
);


ALTER TABLE public.versions OWNER TO pinpoint;

--
-- Name: versions_id_seq; Type: SEQUENCE; Schema: public; Owner: pinpoint
--

CREATE SEQUENCE versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.versions_id_seq OWNER TO pinpoint;

--
-- Name: versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pinpoint
--

ALTER SEQUENCE versions_id_seq OWNED BY versions.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: pinpoint
--

ALTER TABLE ONLY addresses ALTER COLUMN id SET DEFAULT nextval('addresses_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: pinpoint
--

ALTER TABLE ONLY business_managers ALTER COLUMN id SET DEFAULT nextval('business_managers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: pinpoint
--

ALTER TABLE ONLY clients ALTER COLUMN id SET DEFAULT nextval('clients_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: pinpoint
--

ALTER TABLE ONLY comments ALTER COLUMN id SET DEFAULT nextval('comments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: pinpoint
--

ALTER TABLE ONLY departments ALTER COLUMN id SET DEFAULT nextval('departments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: pinpoint
--

ALTER TABLE ONLY distribution_postcodes ALTER COLUMN id SET DEFAULT nextval('distribution_postcodes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: pinpoint
--

ALTER TABLE ONLY distributions ALTER COLUMN id SET DEFAULT nextval('distributions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: pinpoint
--

ALTER TABLE ONLY distributors ALTER COLUMN id SET DEFAULT nextval('distributors_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: pinpoint
--

ALTER TABLE ONLY documents ALTER COLUMN id SET DEFAULT nextval('documents_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: pinpoint
--

ALTER TABLE ONLY export_templates ALTER COLUMN id SET DEFAULT nextval('export_templates_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: pinpoint
--

ALTER TABLE ONLY logotypes ALTER COLUMN id SET DEFAULT nextval('logotypes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: pinpoint
--

ALTER TABLE ONLY messages ALTER COLUMN id SET DEFAULT nextval('messages_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: pinpoint
--

ALTER TABLE ONLY option_values ALTER COLUMN id SET DEFAULT nextval('option_values_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: pinpoint
--

ALTER TABLE ONLY options ALTER COLUMN id SET DEFAULT nextval('options_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: pinpoint
--

ALTER TABLE ONLY orders ALTER COLUMN id SET DEFAULT nextval('orders_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: pinpoint
--

ALTER TABLE ONLY pages ALTER COLUMN id SET DEFAULT nextval('pages_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: pinpoint
--

ALTER TABLE ONLY periods ALTER COLUMN id SET DEFAULT nextval('periods_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: pinpoint
--

ALTER TABLE ONLY postcode_sectors ALTER COLUMN id SET DEFAULT nextval('postcode_sectors_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: pinpoint
--

ALTER TABLE ONLY record_locks ALTER COLUMN id SET DEFAULT nextval('record_locks_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: pinpoint
--

ALTER TABLE ONLY stores ALTER COLUMN id SET DEFAULT nextval('stores_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: pinpoint
--

ALTER TABLE ONLY tasks ALTER COLUMN id SET DEFAULT nextval('tasks_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: pinpoint
--

ALTER TABLE ONLY transports ALTER COLUMN id SET DEFAULT nextval('transports_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: pinpoint
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: pinpoint
--

ALTER TABLE ONLY versions ALTER COLUMN id SET DEFAULT nextval('versions_id_seq'::regclass);


--
-- Name: addresses_pkey; Type: CONSTRAINT; Schema: public; Owner: pinpoint; Tablespace: 
--

ALTER TABLE ONLY addresses
    ADD CONSTRAINT addresses_pkey PRIMARY KEY (id);


--
-- Name: business_managers_pkey; Type: CONSTRAINT; Schema: public; Owner: pinpoint; Tablespace: 
--

ALTER TABLE ONLY business_managers
    ADD CONSTRAINT business_managers_pkey PRIMARY KEY (id);


--
-- Name: clients_pkey; Type: CONSTRAINT; Schema: public; Owner: pinpoint; Tablespace: 
--

ALTER TABLE ONLY clients
    ADD CONSTRAINT clients_pkey PRIMARY KEY (id);


--
-- Name: comments_pkey; Type: CONSTRAINT; Schema: public; Owner: pinpoint; Tablespace: 
--

ALTER TABLE ONLY comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);


--
-- Name: departments_pkey; Type: CONSTRAINT; Schema: public; Owner: pinpoint; Tablespace: 
--

ALTER TABLE ONLY departments
    ADD CONSTRAINT departments_pkey PRIMARY KEY (id);


--
-- Name: distribution_postcodes_pkey; Type: CONSTRAINT; Schema: public; Owner: pinpoint; Tablespace: 
--

ALTER TABLE ONLY distribution_postcodes
    ADD CONSTRAINT distribution_postcodes_pkey PRIMARY KEY (id);


--
-- Name: distributions_pkey; Type: CONSTRAINT; Schema: public; Owner: pinpoint; Tablespace: 
--

ALTER TABLE ONLY distributions
    ADD CONSTRAINT distributions_pkey PRIMARY KEY (id);


--
-- Name: distributors_pkey; Type: CONSTRAINT; Schema: public; Owner: pinpoint; Tablespace: 
--

ALTER TABLE ONLY distributors
    ADD CONSTRAINT distributors_pkey PRIMARY KEY (id);


--
-- Name: documents_pkey; Type: CONSTRAINT; Schema: public; Owner: pinpoint; Tablespace: 
--

ALTER TABLE ONLY documents
    ADD CONSTRAINT documents_pkey PRIMARY KEY (id);


--
-- Name: export_templates_pkey; Type: CONSTRAINT; Schema: public; Owner: pinpoint; Tablespace: 
--

ALTER TABLE ONLY export_templates
    ADD CONSTRAINT export_templates_pkey PRIMARY KEY (id);


--
-- Name: logotypes_pkey; Type: CONSTRAINT; Schema: public; Owner: pinpoint; Tablespace: 
--

ALTER TABLE ONLY logotypes
    ADD CONSTRAINT logotypes_pkey PRIMARY KEY (id);


--
-- Name: messages_pkey; Type: CONSTRAINT; Schema: public; Owner: pinpoint; Tablespace: 
--

ALTER TABLE ONLY messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id);


--
-- Name: option_values_pkey; Type: CONSTRAINT; Schema: public; Owner: pinpoint; Tablespace: 
--

ALTER TABLE ONLY option_values
    ADD CONSTRAINT option_values_pkey PRIMARY KEY (id);


--
-- Name: options_pkey; Type: CONSTRAINT; Schema: public; Owner: pinpoint; Tablespace: 
--

ALTER TABLE ONLY options
    ADD CONSTRAINT options_pkey PRIMARY KEY (id);


--
-- Name: orders_pkey; Type: CONSTRAINT; Schema: public; Owner: pinpoint; Tablespace: 
--

ALTER TABLE ONLY orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (id);


--
-- Name: pages_pkey; Type: CONSTRAINT; Schema: public; Owner: pinpoint; Tablespace: 
--

ALTER TABLE ONLY pages
    ADD CONSTRAINT pages_pkey PRIMARY KEY (id);


--
-- Name: periods_pkey; Type: CONSTRAINT; Schema: public; Owner: pinpoint; Tablespace: 
--

ALTER TABLE ONLY periods
    ADD CONSTRAINT periods_pkey PRIMARY KEY (id);


--
-- Name: postcode_sectors_pkey; Type: CONSTRAINT; Schema: public; Owner: pinpoint; Tablespace: 
--

ALTER TABLE ONLY postcode_sectors
    ADD CONSTRAINT postcode_sectors_pkey PRIMARY KEY (id);


--
-- Name: record_locks_pkey; Type: CONSTRAINT; Schema: public; Owner: pinpoint; Tablespace: 
--

ALTER TABLE ONLY record_locks
    ADD CONSTRAINT record_locks_pkey PRIMARY KEY (id);


--
-- Name: stores_pkey; Type: CONSTRAINT; Schema: public; Owner: pinpoint; Tablespace: 
--

ALTER TABLE ONLY stores
    ADD CONSTRAINT stores_pkey PRIMARY KEY (id);


--
-- Name: tasks_pkey; Type: CONSTRAINT; Schema: public; Owner: pinpoint; Tablespace: 
--

ALTER TABLE ONLY tasks
    ADD CONSTRAINT tasks_pkey PRIMARY KEY (id);


--
-- Name: transports_pkey; Type: CONSTRAINT; Schema: public; Owner: pinpoint; Tablespace: 
--

ALTER TABLE ONLY transports
    ADD CONSTRAINT transports_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: pinpoint; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: versions_pkey; Type: CONSTRAINT; Schema: public; Owner: pinpoint; Tablespace: 
--

ALTER TABLE ONLY versions
    ADD CONSTRAINT versions_pkey PRIMARY KEY (id);


--
-- Name: index_business_managers_on_client_id; Type: INDEX; Schema: public; Owner: pinpoint; Tablespace: 
--

CREATE INDEX index_business_managers_on_client_id ON business_managers USING btree (client_id);


--
-- Name: index_comments_on_commentable_id; Type: INDEX; Schema: public; Owner: pinpoint; Tablespace: 
--

CREATE INDEX index_comments_on_commentable_id ON comments USING btree (commentable_id);


--
-- Name: index_comments_on_user_id; Type: INDEX; Schema: public; Owner: pinpoint; Tablespace: 
--

CREATE INDEX index_comments_on_user_id ON comments USING btree (user_id);


--
-- Name: index_distributions_on_distributor_id; Type: INDEX; Schema: public; Owner: pinpoint; Tablespace: 
--

CREATE INDEX index_distributions_on_distributor_id ON distributions USING btree (distributor_id);


--
-- Name: index_distributions_on_order_id; Type: INDEX; Schema: public; Owner: pinpoint; Tablespace: 
--

CREATE INDEX index_distributions_on_order_id ON distributions USING btree (order_id);


--
-- Name: index_documents_on_order_id; Type: INDEX; Schema: public; Owner: pinpoint; Tablespace: 
--

CREATE INDEX index_documents_on_order_id ON documents USING btree (store_id);


--
-- Name: index_documents_on_user_id; Type: INDEX; Schema: public; Owner: pinpoint; Tablespace: 
--

CREATE INDEX index_documents_on_user_id ON documents USING btree (user_id);


--
-- Name: index_orders_on_option_id; Type: INDEX; Schema: public; Owner: pinpoint; Tablespace: 
--

CREATE INDEX index_orders_on_option_id ON orders USING btree (option_id);


--
-- Name: index_orders_on_period_id; Type: INDEX; Schema: public; Owner: pinpoint; Tablespace: 
--

CREATE INDEX index_orders_on_period_id ON orders USING btree (period_id);


--
-- Name: index_orders_on_store_id; Type: INDEX; Schema: public; Owner: pinpoint; Tablespace: 
--

CREATE INDEX index_orders_on_store_id ON orders USING btree (store_id);


--
-- Name: index_orders_on_user_id; Type: INDEX; Schema: public; Owner: pinpoint; Tablespace: 
--

CREATE INDEX index_orders_on_user_id ON orders USING btree (user_id);


--
-- Name: index_periods_on_client_id; Type: INDEX; Schema: public; Owner: pinpoint; Tablespace: 
--

CREATE INDEX index_periods_on_client_id ON periods USING btree (client_id);


--
-- Name: index_record_locks_on_record_type_and_record_id; Type: INDEX; Schema: public; Owner: pinpoint; Tablespace: 
--

CREATE INDEX index_record_locks_on_record_type_and_record_id ON record_locks USING btree (record_type, record_id);


--
-- Name: index_stores_on_business_manager_id; Type: INDEX; Schema: public; Owner: pinpoint; Tablespace: 
--

CREATE INDEX index_stores_on_business_manager_id ON stores USING btree (business_manager_id);


--
-- Name: index_stores_on_client_id; Type: INDEX; Schema: public; Owner: pinpoint; Tablespace: 
--

CREATE INDEX index_stores_on_client_id ON stores USING btree (client_id);


--
-- Name: index_stores_on_logotype_id; Type: INDEX; Schema: public; Owner: pinpoint; Tablespace: 
--

CREATE INDEX index_stores_on_logotype_id ON stores USING btree (logotype_id);


--
-- Name: index_stores_on_user_id; Type: INDEX; Schema: public; Owner: pinpoint; Tablespace: 
--

CREATE INDEX index_stores_on_user_id ON stores USING btree (user_id);


--
-- Name: index_tasks_on_department_id; Type: INDEX; Schema: public; Owner: pinpoint; Tablespace: 
--

CREATE INDEX index_tasks_on_department_id ON tasks USING btree (department_id);


--
-- Name: index_tasks_on_order_id; Type: INDEX; Schema: public; Owner: pinpoint; Tablespace: 
--

CREATE INDEX index_tasks_on_order_id ON tasks USING btree (store_id);


--
-- Name: index_tasks_on_user_id; Type: INDEX; Schema: public; Owner: pinpoint; Tablespace: 
--

CREATE INDEX index_tasks_on_user_id ON tasks USING btree (user_id);


--
-- Name: index_transports_on_user_id; Type: INDEX; Schema: public; Owner: pinpoint; Tablespace: 
--

CREATE INDEX index_transports_on_user_id ON transports USING btree (user_id);


--
-- Name: index_users_on_approved; Type: INDEX; Schema: public; Owner: pinpoint; Tablespace: 
--

CREATE INDEX index_users_on_approved ON users USING btree (approved);


--
-- Name: index_users_on_department_id; Type: INDEX; Schema: public; Owner: pinpoint; Tablespace: 
--

CREATE INDEX index_users_on_department_id ON users USING btree (department_id);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: pinpoint; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_email ON users USING btree (email);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: pinpoint; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON users USING btree (reset_password_token);


--
-- Name: index_versions_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: pinpoint; Tablespace: 
--

CREATE INDEX index_versions_on_item_type_and_item_id ON versions USING btree (item_type, item_id);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: pinpoint; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

