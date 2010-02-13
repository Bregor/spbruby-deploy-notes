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
-- Name: plpgsql; Type: PROCEDURAL LANGUAGE; Schema: -; Owner: mail
--

CREATE PROCEDURAL LANGUAGE plpgsql;


ALTER PROCEDURAL LANGUAGE plpgsql OWNER TO mail;

SET search_path = public, pg_catalog;

--
-- Name: merge_quota(); Type: FUNCTION; Schema: public; Owner: mail
--

CREATE FUNCTION merge_quota() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
        BEGIN
            UPDATE quota SET current = NEW.current + current WHERE username = NEW.username AND path = NEW.path;
            IF found THEN
                RETURN NULL;
            ELSE
                RETURN NEW;
            END IF;
      END;
      $$;


ALTER FUNCTION public.merge_quota() OWNER TO mail;

--
-- Name: merge_quota2(); Type: FUNCTION; Schema: public; Owner: mail
--

CREATE FUNCTION merge_quota2() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
        BEGIN
            IF NEW.messages < 0 OR NEW.messages IS NULL THEN
                -- ugly kludge: we came here from this function, really do try to insert
                IF NEW.messages IS NULL THEN
                    NEW.messages = 0;
                ELSE
                    NEW.messages = -NEW.messages;
                END IF;
                return NEW;
            END IF;

            LOOP
                UPDATE quota2 SET bytes = bytes + NEW.bytes,
                    messages = messages + NEW.messages
                    WHERE username = NEW.username;
                IF found THEN
                    RETURN NULL;
                END IF;

                BEGIN
                    IF NEW.messages = 0 THEN
                    INSERT INTO quota2 (bytes, messages, username) VALUES (NEW.bytes, NULL, NEW.username);
                    ELSE
                        INSERT INTO quota2 (bytes, messages, username) VALUES (NEW.bytes, -NEW.messages, NEW.username);
                    END IF;
                    return NULL;
                    EXCEPTION WHEN unique_violation THEN
                    -- someone just inserted the record, update it
                END;
            END LOOP;
        END;
        $$;


ALTER FUNCTION public.merge_quota2() OWNER TO mail;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: admin; Type: TABLE; Schema: public; Owner: mail; Tablespace: 
--

CREATE TABLE admin (
    username character varying(255) NOT NULL,
    password character varying(255) DEFAULT ''::character varying NOT NULL,
    created timestamp with time zone DEFAULT now(),
    modified timestamp with time zone DEFAULT now(),
    active boolean DEFAULT true NOT NULL
);


ALTER TABLE public.admin OWNER TO mail;

--
-- Name: TABLE admin; Type: COMMENT; Schema: public; Owner: mail
--

COMMENT ON TABLE admin IS 'Postfix Admin - Virtual Admins';


--
-- Name: alias; Type: TABLE; Schema: public; Owner: mail; Tablespace: 
--

CREATE TABLE alias (
    address character varying(255) NOT NULL,
    goto text NOT NULL,
    domain character varying(255) NOT NULL,
    created timestamp with time zone DEFAULT now(),
    modified timestamp with time zone DEFAULT now(),
    active boolean DEFAULT true NOT NULL
);


ALTER TABLE public.alias OWNER TO mail;

--
-- Name: TABLE alias; Type: COMMENT; Schema: public; Owner: mail
--

COMMENT ON TABLE alias IS 'Postfix Admin - Virtual Aliases';


--
-- Name: alias_domain; Type: TABLE; Schema: public; Owner: mail; Tablespace: 
--

CREATE TABLE alias_domain (
    alias_domain character varying(255) NOT NULL,
    target_domain character varying(255) NOT NULL,
    created timestamp with time zone DEFAULT now(),
    modified timestamp with time zone DEFAULT now(),
    active boolean DEFAULT true NOT NULL
);


ALTER TABLE public.alias_domain OWNER TO mail;

--
-- Name: TABLE alias_domain; Type: COMMENT; Schema: public; Owner: mail
--

COMMENT ON TABLE alias_domain IS 'Postfix Admin - Domain Aliases';


--
-- Name: config; Type: TABLE; Schema: public; Owner: mail; Tablespace: 
--

CREATE TABLE config (
    id integer NOT NULL,
    name character varying(20) NOT NULL,
    value character varying(20) NOT NULL
);


ALTER TABLE public.config OWNER TO mail;

--
-- Name: config_id_seq; Type: SEQUENCE; Schema: public; Owner: mail
--

CREATE SEQUENCE config_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.config_id_seq OWNER TO mail;

--
-- Name: config_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: mail
--

ALTER SEQUENCE config_id_seq OWNED BY config.id;


--
-- Name: config_id_seq; Type: SEQUENCE SET; Schema: public; Owner: mail
--

SELECT pg_catalog.setval('config_id_seq', 1, true);


--
-- Name: domain; Type: TABLE; Schema: public; Owner: mail; Tablespace: 
--

CREATE TABLE domain (
    domain character varying(255) NOT NULL,
    description character varying(255) DEFAULT ''::character varying NOT NULL,
    aliases integer DEFAULT 0 NOT NULL,
    mailboxes integer DEFAULT 0 NOT NULL,
    maxquota integer DEFAULT 0 NOT NULL,
    quota integer DEFAULT 0 NOT NULL,
    transport character varying(255) DEFAULT NULL::character varying,
    backupmx boolean DEFAULT false NOT NULL,
    created timestamp with time zone DEFAULT now(),
    modified timestamp with time zone DEFAULT now(),
    active boolean DEFAULT true NOT NULL
);


ALTER TABLE public.domain OWNER TO mail;

--
-- Name: TABLE domain; Type: COMMENT; Schema: public; Owner: mail
--

COMMENT ON TABLE domain IS 'Postfix Admin - Virtual Domains';


--
-- Name: domain_admins; Type: TABLE; Schema: public; Owner: mail; Tablespace: 
--

CREATE TABLE domain_admins (
    username character varying(255) NOT NULL,
    domain character varying(255) NOT NULL,
    created timestamp with time zone DEFAULT now(),
    active boolean DEFAULT true NOT NULL
);


ALTER TABLE public.domain_admins OWNER TO mail;

--
-- Name: TABLE domain_admins; Type: COMMENT; Schema: public; Owner: mail
--

COMMENT ON TABLE domain_admins IS 'Postfix Admin - Domain Admins';


--
-- Name: fetchmail; Type: TABLE; Schema: public; Owner: mail; Tablespace: 
--

CREATE TABLE fetchmail (
    id integer NOT NULL,
    mailbox character varying(255) DEFAULT ''::character varying NOT NULL,
    src_server character varying(255) DEFAULT ''::character varying NOT NULL,
    src_auth character varying(15) NOT NULL,
    src_user character varying(255) DEFAULT ''::character varying NOT NULL,
    src_password character varying(255) DEFAULT ''::character varying NOT NULL,
    src_folder character varying(255) DEFAULT ''::character varying NOT NULL,
    poll_time integer DEFAULT 10 NOT NULL,
    fetchall boolean DEFAULT false NOT NULL,
    keep boolean DEFAULT false NOT NULL,
    protocol character varying(15) NOT NULL,
    extra_options text,
    returned_text text,
    mda character varying(255) DEFAULT ''::character varying NOT NULL,
    date timestamp with time zone DEFAULT now(),
    usessl boolean DEFAULT false NOT NULL,
    CONSTRAINT fetchmail_protocol_check CHECK (((protocol)::text = ANY (ARRAY[('POP3'::character varying)::text, ('IMAP'::character varying)::text, ('POP2'::character varying)::text, ('ETRN'::character varying)::text, ('AUTO'::character varying)::text]))),
    CONSTRAINT fetchmail_src_auth_check CHECK (((src_auth)::text = ANY (ARRAY[('password'::character varying)::text, ('kerberos_v5'::character varying)::text, ('kerberos'::character varying)::text, ('kerberos_v4'::character varying)::text, ('gssapi'::character varying)::text, ('cram-md5'::character varying)::text, ('otp'::character varying)::text, ('ntlm'::character varying)::text, ('msn'::character varying)::text, ('ssh'::character varying)::text, ('any'::character varying)::text])))
);


ALTER TABLE public.fetchmail OWNER TO mail;

--
-- Name: fetchmail_id_seq; Type: SEQUENCE; Schema: public; Owner: mail
--

CREATE SEQUENCE fetchmail_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.fetchmail_id_seq OWNER TO mail;

--
-- Name: fetchmail_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: mail
--

ALTER SEQUENCE fetchmail_id_seq OWNED BY fetchmail.id;


--
-- Name: fetchmail_id_seq; Type: SEQUENCE SET; Schema: public; Owner: mail
--

SELECT pg_catalog.setval('fetchmail_id_seq', 1, true);


--
-- Name: greylist; Type: TABLE; Schema: public; Owner: mail; Tablespace: 
--

CREATE TABLE greylist (
    id integer NOT NULL,
    relay_ip character varying(20),
    sender_type character varying(6) DEFAULT 'NORMAL'::character varying NOT NULL,
    sender character varying(150),
    recipient character varying(150),
    block_expires timestamp without time zone DEFAULT '0001-01-01 00:00:00'::timestamp without time zone NOT NULL,
    record_expires timestamp without time zone DEFAULT '9999-12-31 23:59:59'::timestamp without time zone NOT NULL,
    create_time timestamp without time zone DEFAULT '0001-01-01 00:00:00'::timestamp without time zone NOT NULL,
    type character varying(6) DEFAULT 'MANUAL'::character varying NOT NULL,
    passcount bigint DEFAULT (0)::bigint NOT NULL,
    last_pass timestamp without time zone DEFAULT '0001-01-01 00:00:00'::timestamp without time zone NOT NULL,
    blockcount bigint DEFAULT (0)::bigint NOT NULL,
    last_block timestamp without time zone DEFAULT '0001-01-01 00:00:00'::timestamp without time zone NOT NULL,
    CONSTRAINT greylist_sender_type_check CHECK ((((sender_type)::text = 'NORMAL'::text) OR ((sender_type)::text = 'BOUNCE'::text))),
    CONSTRAINT greylist_type_check CHECK ((((type)::text = 'AUTO'::text) OR ((type)::text = 'MANUAL'::text)))
);


ALTER TABLE public.greylist OWNER TO mail;

--
-- Name: greylist_id_seq; Type: SEQUENCE; Schema: public; Owner: mail
--

CREATE SEQUENCE greylist_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.greylist_id_seq OWNER TO mail;

--
-- Name: greylist_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: mail
--

ALTER SEQUENCE greylist_id_seq OWNED BY greylist.id;


--
-- Name: greylist_id_seq; Type: SEQUENCE SET; Schema: public; Owner: mail
--

SELECT pg_catalog.setval('greylist_id_seq', 1, false);


--
-- Name: greylist_log; Type: TABLE; Schema: public; Owner: mail; Tablespace: 
--

CREATE TABLE greylist_log (
    id integer NOT NULL,
    listid bigint DEFAULT (0)::bigint NOT NULL,
    "timestamp" timestamp without time zone DEFAULT '0001-01-01 00:00:00'::timestamp without time zone NOT NULL,
    kind character varying(8) DEFAULT 'deferred'::character varying NOT NULL,
    CONSTRAINT greylist_log_kind_check CHECK ((((kind)::text = 'deferred'::text) OR ((kind)::text = 'accepted'::text)))
);


ALTER TABLE public.greylist_log OWNER TO mail;

--
-- Name: greylist_log_id_seq; Type: SEQUENCE; Schema: public; Owner: mail
--

CREATE SEQUENCE greylist_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.greylist_log_id_seq OWNER TO mail;

--
-- Name: greylist_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: mail
--

ALTER SEQUENCE greylist_log_id_seq OWNED BY greylist_log.id;


--
-- Name: greylist_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: mail
--

SELECT pg_catalog.setval('greylist_log_id_seq', 1, false);


--
-- Name: log; Type: TABLE; Schema: public; Owner: mail; Tablespace: 
--

CREATE TABLE log (
    "timestamp" timestamp with time zone DEFAULT now(),
    username character varying(255) DEFAULT ''::character varying NOT NULL,
    domain character varying(255) DEFAULT ''::character varying NOT NULL,
    action character varying(255) DEFAULT ''::character varying NOT NULL,
    data text DEFAULT ''::text NOT NULL
);


ALTER TABLE public.log OWNER TO mail;

--
-- Name: TABLE log; Type: COMMENT; Schema: public; Owner: mail
--

COMMENT ON TABLE log IS 'Postfix Admin - Log';


--
-- Name: mailbox; Type: TABLE; Schema: public; Owner: mail; Tablespace: 
--

CREATE TABLE mailbox (
    username character varying(255) NOT NULL,
    password character varying(255) DEFAULT ''::character varying NOT NULL,
    name character varying(255) DEFAULT ''::character varying NOT NULL,
    maildir character varying(255) DEFAULT ''::character varying NOT NULL,
    quota integer DEFAULT 0 NOT NULL,
    created timestamp with time zone DEFAULT now(),
    modified timestamp with time zone DEFAULT now(),
    active boolean DEFAULT true NOT NULL,
    domain character varying(255),
    local_part character varying(255) NOT NULL
);


ALTER TABLE public.mailbox OWNER TO mail;

--
-- Name: TABLE mailbox; Type: COMMENT; Schema: public; Owner: mail
--

COMMENT ON TABLE mailbox IS 'Postfix Admin - Virtual Mailboxes';


--
-- Name: quota; Type: TABLE; Schema: public; Owner: mail; Tablespace: 
--

CREATE TABLE quota (
    username character varying(255) NOT NULL,
    path character varying(100) NOT NULL,
    current bigint
);


ALTER TABLE public.quota OWNER TO mail;

--
-- Name: quota2; Type: TABLE; Schema: public; Owner: mail; Tablespace: 
--

CREATE TABLE quota2 (
    username character varying(100) NOT NULL,
    bytes bigint DEFAULT 0 NOT NULL,
    messages integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.quota2 OWNER TO mail;

--
-- Name: vacation; Type: TABLE; Schema: public; Owner: mail; Tablespace: 
--

CREATE TABLE vacation (
    email character varying(255) NOT NULL,
    subject character varying(255) NOT NULL,
    body text DEFAULT ''::text NOT NULL,
    created timestamp with time zone DEFAULT now(),
    active boolean DEFAULT true NOT NULL,
    domain character varying(255)
);


ALTER TABLE public.vacation OWNER TO mail;

--
-- Name: vacation_notification; Type: TABLE; Schema: public; Owner: mail; Tablespace: 
--

CREATE TABLE vacation_notification (
    on_vacation character varying(255) NOT NULL,
    notified character varying(255) NOT NULL,
    notified_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.vacation_notification OWNER TO mail;

--
-- Name: id; Type: DEFAULT; Schema: public; Owner: mail
--

ALTER TABLE config ALTER COLUMN id SET DEFAULT nextval('config_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: mail
--

ALTER TABLE fetchmail ALTER COLUMN id SET DEFAULT nextval('fetchmail_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: mail
--

ALTER TABLE greylist ALTER COLUMN id SET DEFAULT nextval('greylist_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: mail
--

ALTER TABLE greylist_log ALTER COLUMN id SET DEFAULT nextval('greylist_log_id_seq'::regclass);


--
-- Data for Name: admin; Type: TABLE DATA; Schema: public; Owner: mail
--

COPY admin (username, password, created, modified, active) FROM stdin;
spbruby@spbruby.org	superduper	2009-11-19 13:29:01.575007+03	2009-11-19 13:47:27.643191+03	t
\.


--
-- Data for Name: alias; Type: TABLE DATA; Schema: public; Owner: mail
--

COPY alias (address, goto, domain, created, modified, active) FROM stdin;
spbruby@spbruby.org	spbruby@spbruby.org	spbruby.org	2009-11-18 18:04:22.461352+03	2009-11-18 18:04:22.461352+03	t
\.


--
-- Data for Name: alias_domain; Type: TABLE DATA; Schema: public; Owner: mail
--

COPY alias_domain (alias_domain, target_domain, created, modified, active) FROM stdin;
\.


--
-- Data for Name: config; Type: TABLE DATA; Schema: public; Owner: mail
--

COPY config (id, name, value) FROM stdin;
1	version	738
\.


--
-- Data for Name: domain; Type: TABLE DATA; Schema: public; Owner: mail
--

COPY domain (domain, description, aliases, mailboxes, maxquota, quota, transport, backupmx, created, modified, active) FROM stdin;
ALL		0	0	0	0	\N	f	2009-11-18 17:37:59.974439+03	2009-11-18 17:37:59.974439+03	t
spbruby.org	Main domain	0	0	10	0	virtual	f	2009-11-18 17:41:38.874475+03	2009-11-18 17:41:38.874475+03	t
\.


--
-- Data for Name: domain_admins; Type: TABLE DATA; Schema: public; Owner: mail
--

COPY domain_admins (username, domain, created, active) FROM stdin;
spbruby@spbruby.org	ALL	2009-11-19 13:47:27.64424+03	t
\.


--
-- Data for Name: fetchmail; Type: TABLE DATA; Schema: public; Owner: mail
--

COPY fetchmail (id, mailbox, src_server, src_auth, src_user, src_password, src_folder, poll_time, fetchall, keep, protocol, extra_options, returned_text, mda, date, usessl) FROM stdin;
\.


--
-- Data for Name: greylist; Type: TABLE DATA; Schema: public; Owner: mail
--

COPY greylist (id, relay_ip, sender_type, sender, recipient, block_expires, record_expires, create_time, type, passcount, last_pass, blockcount, last_block) FROM stdin;
\.


--
-- Data for Name: greylist_log; Type: TABLE DATA; Schema: public; Owner: mail
--

COPY greylist_log (id, listid, "timestamp", kind) FROM stdin;
\.


--
-- Data for Name: log; Type: TABLE DATA; Schema: public; Owner: mail
--

COPY log ("timestamp", username, domain, action, data) FROM stdin;
2009-11-18 18:04:22.46267+03	spbruby@spbruby.org (192.168.0.116)	spbruby.org	create_mailbox	spbruby@spbruby.org
\.


--
-- Data for Name: mailbox; Type: TABLE DATA; Schema: public; Owner: mail
--

COPY mailbox (username, password, name, maildir, quota, created, modified, active, domain, local_part) FROM stdin;
spbruby@spbruby.org	superduper	Spb Ruby	spbruby.org/spbruby	102400000	2009-11-18 18:04:22.461352+03	2009-11-25 18:19:58.184068+03	t	spbruby.org	spbruby
\.


--
-- Data for Name: quota; Type: TABLE DATA; Schema: public; Owner: mail
--

COPY quota (username, path, current) FROM stdin;
\.


--
-- Data for Name: quota2; Type: TABLE DATA; Schema: public; Owner: mail
--

COPY quota2 (username, bytes, messages) FROM stdin;
\.


--
-- Data for Name: vacation; Type: TABLE DATA; Schema: public; Owner: mail
--

COPY vacation (email, subject, body, created, active, domain) FROM stdin;
\.


--
-- Data for Name: vacation_notification; Type: TABLE DATA; Schema: public; Owner: mail
--

COPY vacation_notification (on_vacation, notified, notified_at) FROM stdin;
\.


--
-- Name: admin_key; Type: CONSTRAINT; Schema: public; Owner: mail; Tablespace: 
--

ALTER TABLE ONLY admin
    ADD CONSTRAINT admin_key PRIMARY KEY (username);


--
-- Name: alias_domain_pkey; Type: CONSTRAINT; Schema: public; Owner: mail; Tablespace: 
--

ALTER TABLE ONLY alias_domain
    ADD CONSTRAINT alias_domain_pkey PRIMARY KEY (alias_domain);


--
-- Name: alias_key; Type: CONSTRAINT; Schema: public; Owner: mail; Tablespace: 
--

ALTER TABLE ONLY alias
    ADD CONSTRAINT alias_key PRIMARY KEY (address);


--
-- Name: config_name_key; Type: CONSTRAINT; Schema: public; Owner: mail; Tablespace: 
--

ALTER TABLE ONLY config
    ADD CONSTRAINT config_name_key UNIQUE (name);


--
-- Name: config_pkey; Type: CONSTRAINT; Schema: public; Owner: mail; Tablespace: 
--

ALTER TABLE ONLY config
    ADD CONSTRAINT config_pkey PRIMARY KEY (id);


--
-- Name: domain_key; Type: CONSTRAINT; Schema: public; Owner: mail; Tablespace: 
--

ALTER TABLE ONLY domain
    ADD CONSTRAINT domain_key PRIMARY KEY (domain);


--
-- Name: fetchmail_pkey; Type: CONSTRAINT; Schema: public; Owner: mail; Tablespace: 
--

ALTER TABLE ONLY fetchmail
    ADD CONSTRAINT fetchmail_pkey PRIMARY KEY (id);


--
-- Name: mailbox_key; Type: CONSTRAINT; Schema: public; Owner: mail; Tablespace: 
--

ALTER TABLE ONLY mailbox
    ADD CONSTRAINT mailbox_key PRIMARY KEY (username);


--
-- Name: quota2_pkey; Type: CONSTRAINT; Schema: public; Owner: mail; Tablespace: 
--

ALTER TABLE ONLY quota2
    ADD CONSTRAINT quota2_pkey PRIMARY KEY (username);


--
-- Name: quota_pkey; Type: CONSTRAINT; Schema: public; Owner: mail; Tablespace: 
--

ALTER TABLE ONLY quota
    ADD CONSTRAINT quota_pkey PRIMARY KEY (username, path);


--
-- Name: vacation_notification_pkey; Type: CONSTRAINT; Schema: public; Owner: mail; Tablespace: 
--

ALTER TABLE ONLY vacation_notification
    ADD CONSTRAINT vacation_notification_pkey PRIMARY KEY (on_vacation, notified);


--
-- Name: vacation_pkey; Type: CONSTRAINT; Schema: public; Owner: mail; Tablespace: 
--

ALTER TABLE ONLY vacation
    ADD CONSTRAINT vacation_pkey PRIMARY KEY (email);


--
-- Name: alias_address_active; Type: INDEX; Schema: public; Owner: mail; Tablespace: 
--

CREATE INDEX alias_address_active ON alias USING btree (address, active);


--
-- Name: alias_domain_active; Type: INDEX; Schema: public; Owner: mail; Tablespace: 
--

CREATE INDEX alias_domain_active ON alias_domain USING btree (alias_domain, active);


--
-- Name: alias_domain_idx; Type: INDEX; Schema: public; Owner: mail; Tablespace: 
--

CREATE INDEX alias_domain_idx ON alias USING btree (domain);


--
-- Name: domain_domain_active; Type: INDEX; Schema: public; Owner: mail; Tablespace: 
--

CREATE INDEX domain_domain_active ON domain USING btree (domain, active);


--
-- Name: mailbox_domain_idx; Type: INDEX; Schema: public; Owner: mail; Tablespace: 
--

CREATE INDEX mailbox_domain_idx ON mailbox USING btree (domain);


--
-- Name: mailbox_username_active; Type: INDEX; Schema: public; Owner: mail; Tablespace: 
--

CREATE INDEX mailbox_username_active ON mailbox USING btree (username, active);


--
-- Name: vacation_email_active; Type: INDEX; Schema: public; Owner: mail; Tablespace: 
--

CREATE INDEX vacation_email_active ON vacation USING btree (email, active);


--
-- Name: mergequota; Type: TRIGGER; Schema: public; Owner: mail
--

CREATE TRIGGER mergequota
    BEFORE INSERT ON quota
    FOR EACH ROW
    EXECUTE PROCEDURE merge_quota();


--
-- Name: mergequota2; Type: TRIGGER; Schema: public; Owner: mail
--

CREATE TRIGGER mergequota2
    BEFORE INSERT ON quota2
    FOR EACH ROW
    EXECUTE PROCEDURE merge_quota2();


--
-- Name: alias_domain_alias_domain_fkey; Type: FK CONSTRAINT; Schema: public; Owner: mail
--

ALTER TABLE ONLY alias_domain
    ADD CONSTRAINT alias_domain_alias_domain_fkey FOREIGN KEY (alias_domain) REFERENCES domain(domain) ON DELETE CASCADE;


--
-- Name: alias_domain_fkey; Type: FK CONSTRAINT; Schema: public; Owner: mail
--

ALTER TABLE ONLY alias
    ADD CONSTRAINT alias_domain_fkey FOREIGN KEY (domain) REFERENCES domain(domain);


--
-- Name: alias_domain_target_domain_fkey; Type: FK CONSTRAINT; Schema: public; Owner: mail
--

ALTER TABLE ONLY alias_domain
    ADD CONSTRAINT alias_domain_target_domain_fkey FOREIGN KEY (target_domain) REFERENCES domain(domain) ON DELETE CASCADE;


--
-- Name: domain_admins_domain_fkey; Type: FK CONSTRAINT; Schema: public; Owner: mail
--

ALTER TABLE ONLY domain_admins
    ADD CONSTRAINT domain_admins_domain_fkey FOREIGN KEY (domain) REFERENCES domain(domain);


--
-- Name: mailbox_domain_fkey; Type: FK CONSTRAINT; Schema: public; Owner: mail
--

ALTER TABLE ONLY mailbox
    ADD CONSTRAINT mailbox_domain_fkey FOREIGN KEY (domain) REFERENCES domain(domain);


--
-- Name: vacation_domain_fkey; Type: FK CONSTRAINT; Schema: public; Owner: mail
--

ALTER TABLE ONLY vacation
    ADD CONSTRAINT vacation_domain_fkey FOREIGN KEY (domain) REFERENCES domain(domain);


--
-- Name: vacation_notification_on_vacation_fkey; Type: FK CONSTRAINT; Schema: public; Owner: mail
--

ALTER TABLE ONLY vacation_notification
    ADD CONSTRAINT vacation_notification_on_vacation_fkey FOREIGN KEY (on_vacation) REFERENCES vacation(email) ON DELETE CASCADE;


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

