:- module(model_RDFS,
    [ is_resource(r),
      is_property(r),
      is_literal(r),
      is_datatype(r),
      has_type(r,r),
      has_range(r,r),
      has_domain(r,r),
      has_label(r,?),
      has_comment(r,?),
      is_rdf_list(r,t)
    ]).
/** <module> The Resource Description Framework Schema model.

@author Daniel Beßler
*/

:- use_module(library('semweb/rdf_db'),
	[ rdf_register_ns/3
	]).

:- rdf_register_ns(rdfs,
	'http://www.w3.org/2000/01/rdf-schema#', [keep(true)]).

%% is_resource(+Entity) is semidet.
%
% All things described by RDF are called resources,
% and are instances of the class rdfs:Resource.
% This is the class of everything.
% All other classes are subclasses of this class.
% rdfs:Resource is an instance of rdfs:Class.
%
% @param Entity An entity IRI.
%
is_resource(Entity) ?+>
	has_type(Entity, rdfs:'Resource').

%% is_property(+Entity) is semidet.
%
% rdf:Property is the class of RDF properties.
% rdf:Property is an instance of rdfs:Class.
%
% @param Entity An entity IRI.
%
is_property(Entity) ?+>
	has_type(Entity, rdf:'Property').

%% is_literal(+Entity) is semidet.
%
% The class rdfs:Literal is the class of literal values such as
% strings and integers. Property values such as textual strings
% are examples of RDF literals.
%
% rdfs:Literal is an instance of rdfs:Class.
% rdfs:Literal is a subclass of rdfs:Resource.
%
% @param Entity An entity IRI.
%
is_literal(Entity) ?+>
	has_type(Entity, rdfs:'Literal').

%% is_datatype(+Entity) is semidet.
%
% rdfs:Datatype is the class of datatypes.
% All instances of rdfs:Datatype correspond to the RDF model
% of a datatype described in the RDF Concepts specification.
% rdfs:Datatype is both an instance of and a subclass of rdfs:Class.
% Each instance of rdfs:Datatype is a subclass of rdfs:Literal.
%
% @param Entity An entity IRI.
%
is_datatype(Entity) ?+>
	has_type(Entity, rdfs:'Datatype').

%% has_type(+Resource,?Type) is semidet.
%
% rdf:type is an instance of rdf:Property that is used to
% state that a resource is an instance of a class.
%
% @param Resource a RDF resource
% @param Type a rdf:type of the resource
%
has_type(Resource,Type) ?>
	% TODO: this seems not a good idea, e.g. Type could be a regex/1 term.
	pragma(\+ compound(Type)),
	triple(Resource, rdf:type, Type).

has_type(Resource,Type) +>
	instance_of(Resource,Type).

%% has_range(?Property,?Range) is nondet.
%
% The range of a property globally restricts values
% of the property to instances of the range.
%
% @param Property a property
% @param Range the range of the property
%
has_range(Property,Range) ?+>
	triple(Property, rdfs:range, Range).

%% has_domain(?Property,?Domain) is nondet.
%
% The domain of a property globally restricts hosts
% of the property to instances of the domain.
%
% @param Property a property
% @param Domain the range of the property
%
has_domain(Property,Domain) ?+>
	triple(Property, rdfs:domain, Domain).

%% has_label(+Resource,?Comment) is semidet.
%
% rdfs:label is an instance of rdf:Property that may be used
% to provide a human-readable version of a resource's name.
%
% @param Resource a RDF resource
% @param Label a label atom
%
has_label(Resource,Label) ?+>
	triple(Resource, rdfs:label, Label).

%% has_comment(+Resource,?Comment) is semidet.
%
% rdfs:comment is an instance of rdf:Property that may be used
% to provide a human-readable description of a resource.
%
% @param Resource a RDF resource
% @param Comment a comment atom
%
has_comment(Resource,Comment) ?+>
	triple(Resource, rdfs:comment, Comment).

%% is_rdf_list(+RDF_list, -Pl_List) is semidet.
%
%
is_rdf_list(RDF_list, Pl_List) ?>
	ground(RDF_list),
	findall(X,
		(	reflexive(transitive(
				triple(RDF_list,rdf:rest,Ys)
			)),
			triple(Ys, rdf:first, X)
		),
		Pl_List).

is_rdf_list(RDF_list, Pl_List) +>
	pragma(expand_list_(Pl_List, Expanded)),
	call([
		has_type(RDF_list, rdf:'List')
	|	Expanded
	]).

		 /*******************************
		 *	    helper	     		*
		 *******************************/

%%
expand_list_(
		'http://www.w3.org/1999/02/22-rdf-syntax-ns#nil',
		[], []) :-
	!.

expand_list_(This, [Child|Rest],
		[	triple(This, rdf:first, Child),
			has_type(Next, rdf:'List'),
			triple(This, rdf:rest, Next)
		|	Xs
		]) :-
	expand_list_(Next, Rest, Xs).

		 /*******************************
		 *	    UNIT TESTS	     		*
		 *******************************/

:- begin_rdf_tests(
		'model_RDFS',
		'package://knowrob/owl/test/swrl.owl',
		[ namespace('http://knowrob.org/kb/swrl_test#')
		]).

test('is_resource') :-
	assert_true(is_resource(test:'Lea')),
	assert_true(is_resource(test:'Adult')),
	assert_false(is_resource(test:'hasNumber')),
	assert_false(is_resource(test:'NotExisting')).

test('is_property') :-
	assert_true(is_property(test:'hasNumber')),
	assert_false(is_property(test:'Lea')),
	assert_false(is_property(test:'NotExisting')).

:- end_rdf_tests('model_RDFS').
