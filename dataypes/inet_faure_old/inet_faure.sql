---------------------------------------------------------------------------
--
-- inet_faure.sql-
--    This file shows how to create a new user-defined type and how to
--    use this new type.
--
--
-- Portions Copyright (c) 1996-2021, PostgreSQL Global Development Group
-- Portions Copyright (c) 1994, Regents of the University of California
--
-- src/tutorial/inet_faure.source
--
---------------------------------------------------------------------------

-----------------------------
-- Creating a new type:
--	We are going to create a new type called 'inet_faure' which represents
--	inet_faure numbers.
--	A user-defined type must have an input and an output function, and
--	optionally can have binary input and output functions.  All of these
--	are usually user-defined C functions.
-----------------------------

-- Assume the user defined functions are in /home/vagrant/Faure_clones/Faure/dataypes/inet_faure/inet_faure$DLSUFFIX
-- (we do not want to assume this is in the dynamic loader search path).
-- Look at $PWD/inet_faure.c for the source.  Note that we declare all of
-- them as STRICT, so we do not need to cope with NULL inputs in the
-- C code.  We also mark them IMMUTABLE, since they always return the
-- same outputs given the same inputs.

-- the input function 'inet_faure_in' takes a null-terminated string (the
-- textual representation of the type) and turns it into the internal
-- (in memory) representation. You will get a message telling you 'inet_faure'
-- does not exist yet but that's okay.

CREATE FUNCTION inet_faure_in(cstring)
   RETURNS inet_faure
   AS '/home/vagrant/Faure_clones/Faure/dataypes/inet_faure/inet_faure'
   LANGUAGE C IMMUTABLE STRICT;

-- the output function 'inet_faure_out' takes the internal representation and
-- converts it into the textual representation.

CREATE FUNCTION inet_faure_out(inet_faure)
   RETURNS cstring
   AS '/home/vagrant/Faure_clones/Faure/dataypes/inet_faure/inet_faure'
   LANGUAGE C IMMUTABLE STRICT;

-- the binary input function 'inet_faure_recv' takes a StringInfo buffer
-- and turns its contents into the internal representation.

--CREATE FUNCTION inet_faure_recv(internal)
--   RETURNS inet_faure
--   AS '/home/vagrant/Faure_clones/Faure/dataypes/inet_faure/inet_faure'
--   LANGUAGE C IMMUTABLE STRICT;

-- the binary output function 'inet_faure_send' takes the internal representation
-- and converts it into a (hopefully) platform-independent bytea string.

--CREATE FUNCTION inet_faure_send(inet_faure)
--   RETURNS bytea
--   AS '/home/vagrant/Faure_clones/Faure/dataypes/inet_faure/inet_faure'
--   LANGUAGE C IMMUTABLE STRICT;


-- now, we can create the type. The internallength specifies the size of the
-- memory block required to hold the type (we need two 8-byte doubles).

-- TODO: Not specifiying alignment and internal length
CREATE TYPE inet_faure (
   input = inet_faure_in,
   output = inet_faure_out
   -- receive = inet_faure_recv,
   -- send = inet_faure_send,
   -- alignment = double
);


-----------------------------
-- Using the new type:
--	user-defined types can be used like ordinary built-in types.
-----------------------------

-- eg. we can use it in a table

CREATE TABLE test_inet_faure (
	a	inet_faure,
	b	inet_faure
);

-- data for user-defined types are just strings in the proper textual
-- representation.

INSERT INTO test_inet_faure VALUES ('192.168.100.1', '192.168.2.1');
-- INSERT INTO test_inet_faure VALUES ('192.168.100.2', '192.168.20.1');

SELECT * FROM test_inet_faure;

-----------------------------
-- Creating an operator for the new type:
--	Let's define an add operator for inet_faure types. Since POSTGRES
--	supports function overloading, we'll use + as the add operator.
--	(Operator names can be reused with different numbers and types of
--	arguments.)
-----------------------------

-- first, define a function inet_faure_add (also in inet_faure.c)

-- CREATE FUNCTION inet_faure_add(inet_faure, inet_faure)
--    RETURNS inet_faure
--    AS '/home/vagrant/Faure_clones/Faure/dataypes/inet_faure/inet_faure'
--    LANGUAGE C IMMUTABLE STRICT;

-- we can now define the operator. We show a binary operator here but you
-- can also define a prefix operator by omitting the leftarg.

-- CREATE OPERATOR + (
--    leftarg = inet_faure,
--    rightarg = inet_faure,
--    procedure = inet_faure_add,
--    commutator = +
-- );


-- SELECT (a + b) AS c FROM test_inet_faure;

-- Occasionally, you may find it useful to cast the string to the desired
-- type explicitly. :: denotes a type cast.

-- SELECT  a + '(1.0,1.0)'::inet_faure AS aa,
--         b + '(1.0,1.0)'::inet_faure AS bb
--    FROM test_inet_faure;


-----------------------------
-- Creating aggregate functions
--	you can also define aggregate functions. The syntax is somewhat
--	cryptic but the idea is to express the aggregate in terms of state
--	transition functions.
-----------------------------

-- CREATE AGGREGATE inet_faure_sum (
--    sfunc = inet_faure_add,
--    basetype = inet_faure,
--    stype = inet_faure,
--    initcond = '(0,0)'
-- );

-- SELECT inet_faure_sum(a) FROM test_inet_faure;


-----------------------------
-- Interfacing New Types with Indexes:
--	We cannot define a secondary index (eg. a B-tree) over the new type
--	yet. We need to create all the required operators and support
--      functions, then we can make the operator class.
-----------------------------

-- first, define the required operators

-- CREATE FUNCTION inet_faure_abs_lt(inet_faure, inet_faure) RETURNS bool
   -- AS '/home/vagrant/Faure_clones/Faure/dataypes/inet_faure/inet_faure' LANGUAGE C IMMUTABLE STRICT;
-- CREATE FUNCTION inet_faure_abs_le(inet_faure, inet_faure) RETURNS bool
   -- AS '/home/vagrant/Faure_clones/Faure/dataypes/inet_faure/inet_faure' LANGUAGE C IMMUTABLE STRICT;
CREATE FUNCTION inet_faure_eq(inet_faure, inet_faure) RETURNS bool
   AS '/home/vagrant/Faure_clones/Faure/dataypes/inet_faure/inet_faure' LANGUAGE C IMMUTABLE STRICT;
-- CREATE FUNCTION inet_faure_abs_ge(inet_faure, inet_faure) RETURNS bool
   -- AS '/home/vagrant/Faure_clones/Faure/dataypes/inet_faure/inet_faure' LANGUAGE C IMMUTABLE STRICT;
-- CREATE FUNCTION inet_faure_abs_gt(inet_faure, inet_faure) RETURNS bool
   -- AS '/home/vagrant/Faure_clones/Faure/dataypes/inet_faure/inet_faure' LANGUAGE C IMMUTABLE STRICT;

-- CREATE OPERATOR < (
--    leftarg = inet_faure, rightarg = inet_faure, procedure = inet_faure_abs_lt,
--    commutator = > , negator = >= ,
--    restrict = scalarltsel, join = scalarltjoinsel
-- );
-- CREATE OPERATOR <= (
--    leftarg = inet_faure, rightarg = inet_faure, procedure = inet_faure_abs_le,
--    commutator = >= , negator = > ,
--    restrict = scalarlesel, join = scalarlejoinsel
-- );
CREATE OPERATOR = (
   leftarg = inet_faure, rightarg = inet_faure, procedure = inet_faure_eq,
   commutator = = ,
   -- leave out negator since we didn't create <> operator
   -- negator = <> ,
   restrict = eqsel, join = eqjoinsel
);
-- CREATE OPERATOR >= (
--    leftarg = inet_faure, rightarg = inet_faure, procedure = inet_faure_abs_ge,
--    commutator = <= , negator = < ,
--    restrict = scalargesel, join = scalargejoinsel
-- );
-- CREATE OPERATOR > (
--    leftarg = inet_faure, rightarg = inet_faure, procedure = inet_faure_abs_gt,
--    commutator = < , negator = <= ,
--    restrict = scalargtsel, join = scalargtjoinsel
-- );

-- create the support function too
CREATE FUNCTION inet_faure_cmp(inet_faure, inet_faure) RETURNS int4
   AS '/home/vagrant/Faure_clones/Faure/dataypes/inet_faure/inet_faure' LANGUAGE C IMMUTABLE STRICT;

-- now we can make the operator class

-- CREATE OPERATOR CLASS inet_faure_abs_ops
--     DEFAULT FOR TYPE inet_faure USING btree AS
--         OPERATOR        1       < ,
--         OPERATOR        2       <= ,
--         OPERATOR        3       = ,
--         OPERATOR        4       >= ,
--         OPERATOR        5       > ,
--         FUNCTION        1       inet_faure_abs_cmp(inet_faure, inet_faure);


-- now, we can define a btree index on inet_faure types. First, let's populate
-- the table. Note that postgres needs many more tuples to start using the
-- btree index during selects.
-- INSERT INTO test_inet_faure VALUES ('(56.0,-22.5)', '(-43.2,-0.07)');
-- INSERT INTO test_inet_faure VALUES ('(-91.9,33.6)', '(8.6,3.0)');

-- CREATE INDEX test_cplx_ind ON test_inet_faure
--    USING btree(a inet_faure_abs_ops);

-- SELECT * from test_inet_faure where a = '(56.0,-22.5)';
-- SELECT * from test_inet_faure where a < '(56.0,-22.5)';
-- SELECT * from test_inet_faure where a > '(56.0,-22.5)';


-- clean up the example
DROP TABLE test_inet_faure;
DROP TYPE inet_faure CASCADE;
