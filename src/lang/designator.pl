
%:- module(lang_designator,
    %[ xxx/0
    %]).

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% methods for querying OWL entities

%% entity(?Entity, +Descr) is nondet
%
% Query for entity matching an entity description or build
% description for entity.
%
% @param Entity IRI of matching entity
% @param Descr An entity description, OWL individual or class IRI
%
%entity(Entity, Descr) :-
  %var(Descr), !,
  %rdfs_individual_of(Entity,dul:'Entity'),
  %once(entity_head(Entity, [A,TypeBase], _, TypeIri)),
  %entity_generate(Entity, [A,TypeBase], TypeIri, Descr).

%entity(Entity, Descr) :-
  %entity_(Entity, Descr),
  %% make sure it's an individual and not a class
  %once(owl_individual_of(Entity, dul:'Entity')).

%%% Entity type description `a|an object|...`
%entity_(Entity, [a, Type|Descr]) :-
  %nonvar(Type), !,
  %entity_name(Descr, Entity),
  %entity_body(Entity, [a, Type|Descr]).
%entity_(Entity, [an, Type|Descr]) :-
  %nonvar(Type), !,
  %entity_name(Descr, Entity),
  %entity_body(Entity, [an, Type|Descr]).

%%% name of the OWL individual
%entity_(Entity, [[name,EntityName]|Descr]) :-
  %entity_name([name,EntityName], Entity),
  %entity_(Entity, Descr).

%entity_(Entity, [[label,EntityLabel]|Descr]) :-
  %rdf_has(Entity,rdfs:label,literal(EntityLabel)),
  %entity_(Entity, Descr).

%%% ignore type, types are handled in `entity_head`
%entity_(Entity, [[type,Type|_]|Descr]) :-
  %nonvar(Type), !,
  %entity_(Entity, Descr).

%%%
%entity_(Entity, [[P,only(Type)]|Descr]) :-
  %property_range(Entity,P,Type),
  %entity_(Entity, Descr).

%entity_(Entity, [[P,some(Type)]|Descr]) :-
  %property_cardinality(Entity,P,Type,Min,_), Min > 0,
  %entity_(Entity, Descr).

%entity_(Entity, [[P,exactly(Count,Type)]|Descr]) :-
  %property_cardinality(Entity,P,Type,Count,Count),
  %entity_(Entity, Descr).

%entity_(Entity, [[P,min(Count,Type)]|Descr]) :-
  %property_cardinality(Entity,P,Type,Count,_),
  %entity_(Entity, Descr).

%entity_(Entity, [[P,max(Count,Type)]|Descr]) :-
  %property_cardinality(Entity,P,Type,_,Count),
  %entity_(Entity, Descr).

%%% key-value property
%% TODO: support specification of property units
%%    - [an, object, [height, 20, qudt:meter]]
%%    - [an, object, [height, 20, qudt:meter, during, Interval]]
%entity_(Entity, [[Key,Value|ValDescr]|Descr]) :-
  %nonvar(Key),
  %entity_iri(PropIri, Key, lower_camelcase),
  
  %(nonvar(ValDescr)
  %-> entity_time_(ValDescr, Time) ;
     %true
  %),
  
  %(nonvar(Value)
  %-> (
    %rdf_has(PropIri, rdf:type, owl:'DatatypeProperty')
    %-> holds(Entity,PropIri,Value,Time) ; (
       %entity_object_value(PropValue, Value),
       %holds(Entity,PropIri,PropValue,Time)
    %)
  %) ; holds(Entity,PropIri,Value,Time)
  %),
  
  %entity_(Entity, Descr).

%entity_(_, []).


%%% Nested object description
%entity_object_value(Iri, Value) :-
  %is_list(Value), !,
  %entity(Iri, Value).
%%% Object iri
%entity_object_value(Iri, Value) :-
  %once( var(Iri) ; atom(Iri) ),
  %entity_ns(Value, NS, ValueUnderscore),
  %atom(NS), atom(ValueUnderscore),
  %camelcase(ValueUnderscore, ValueCamel),
  %atom_concat(NS, ValueCamel, Iri), !.
%%% Object iri
%entity_object_value(Iri, Value) :-
  %rdf_global_term(Value, Iri), !.


%%% Handle description
%entity_body(Entity, [A, Type|Descr]) :-
  %entity_head(Entity, [A,Type], Descr, _),
  %entity_(Entity, Descr),
  %% check general type last because it matches many entities
  %entity_type([A,Type], TypeIri),
  %( var(Entity) ->
    %owl_individual_of(Entity, TypeIri) ;
    %once(owl_individual_of(Entity, TypeIri))).


%%% "name" keys in the description
%entity_name(Descr, Entity) :-
  %entity_has(Descr,name,Name),
  %!, % names must match!
  %rdf_global_term(Name, Entity),
  %(   rdf_has(Entity, _, _)
  %-> true
  %;  entity_iri(Entity, Name, camelcase) ), !.
%entity_name(_, _).


%%% entity_has(+Descr, +Key, Value).
%% Read entity description value
%entity_has([[Key,Val|_]|_], Key, Val).
%entity_has([_|Tail], Key, Val) :- entity_has(Tail, Key, Val).


%%% entity_type(?Descr, ?Iri) is det.
%%
%% Maps ectity type description to IRI
%%
%% @param Descr The type description "[a,an] ?type_name"
%% @param Iri The corresponding type iri
%%
%entity_type([a,pose],       'http://knowrob.org/kb/knowrob.owl#Pose').
%entity_type([a,trajectory], 'http://knowrob.org/kb/knowrob.owl#Trajectory').
%entity_type([an,action],    'http://www.ontologydesignpatterns.org/ont/dul/DUL.owl#Action').
%entity_type([an,event],     'http://www.ontologydesignpatterns.org/ont/dul/DUL.owl#Event').
%entity_type([an,object],    'http://www.ontologydesignpatterns.org/ont/dul/DUL.owl#PhysicalObject').
%entity_type([a,thing],      'http://www.ontologydesignpatterns.org/ont/dul/DUL.owl#Entity').

%entity_type(Entity, TypeBase, Entity) :-
  %atom(Entity), rdf_reachable(Entity, rdfs:subClassOf, TypeBase), !.

%entity_type(Entity, TypeBase, Type) :-
  %rdf_has(Entity, rdf:type, Type),
  %rdf_reachable(Type, rdfs:subClassOf, TypeBase).

%% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
%% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
%% helper

%entity_time_([during,Time|_], Time) :- !.
%entity_time_([_|Xs], Time) :-
  %entity_time_(Xs, Time).

%entity_properties([['http://www.w3.org/1999/02/22-rdf-syntax-ns#type',_]|Tail], DescrTail) :-
  %entity_properties(Tail, DescrTail), !.

%entity_properties([[PropIri,_]|Tail], DescrTail) :-
  %rdf_has(PropIri, rdf:type, owl:'AnnotationProperty'),
  %entity_properties(Tail, DescrTail), !.

%entity_properties([['http://www.w3.org/2000/01/rdf-schema#comment',_]|Tail], DescrTail) :-
  %entity_properties(Tail, DescrTail), !.

%entity_properties([['http://www.w3.org/2000/01/rdf-schema#subClassOf',_]|Tail], DescrTail) :-
  %entity_properties(Tail, DescrTail), !.

%entity_properties([[inverse_of(_),_]|Tail], DescrTail) :-
  %entity_properties(Tail, DescrTail), !.

%entity_properties([[PropIri,IntervalIri]|Tail],
                  %[[Key, [an,interval,Interval]]|DescrTail]) :-
  %once((nonvar(IntervalIri);nonvar(Interval))),
  %interval(IntervalIri,Interval),
  %entity_iri(PropIri, Key, lower_camelcase),
  %entity_properties(Tail, DescrTail), !.

%entity_properties([[PropIri,PropValue]|Tail], [[Key,Value]|DescrTail]) :-
  %entity_iri(PropIri, Key, lower_camelcase),
  %% match rdf value with description value
  %(  rdf_has(PropIri, rdf:type, owl:'DatatypeProperty')
  %-> (var(Value) -> strip_literal_type(PropValue, Value) ; rdf_global_term(Value, PropValue))
  %;  PropValue = Value
  %%;  entity(PropValue, Value)
  %),
  %entity_properties(Tail, DescrTail).

%entity_properties([], []).

%%%
%entity_generate(Pose, [a, pose], _, [a, pose, [X,Y,Z], [QW,QX,QY,QZ]]) :-
  %kb_triple(Pose, knowrob:translation, [X,Y,Z]),
  %kb_triple(Pose, knowrob:quaternion, [QW,QX,QY,QZ]), !.

%entity_generate(Entity, [A,TypeBase], TypeBaseIri, [A,TypeBase|[[type,TypeName]|PropDescr]]) :-
  %(( rdf_has(Entity, rdf:type, Type),
     %Type \= TypeBaseIri,
     %rdf_reachable(Type, rdfs:subClassOf, TypeBaseIri) )
  %-> TypeIri = Type
  %;  TypeIri = TypeBaseIri ),
  %entity_iri(TypeIri, TypeName, camelcase),
  %findall([PropIri,PropValue], rdf(Entity, PropIri, PropValue), Props),
  %entity_properties(Props, PropDescr), !.

%%% Match [a|an, ?entity_type]
%entity_head(Entity, _, Descr, TypeIri) :-
  %var(Entity),
  
  %findall(TypeIri, (
    %entity_has(Descr, type, TypeDescr),
    %\+ TypeDescr = restriction(_,_),
    %once(
    %entity_iri(TypeIri, TypeDescr, camelcase) ;
    %rdf_global_term(TypeDescr, TypeIri) )
  %), Types),
  
  %( Types=[]
  %-> true
  %; (
    %get_time(Time),
    %'knowrob/lang/ask':vkb(_{during:Time},DB),
    %findall(E, (
      %% TODO: it might not allways be best to early resolve the entities,
      %%       also there could be many of them!
      %owl_individual_of_all(Types, E, DB)
    %), Entities),
    %% avoid redundant results of owl_individual_of
    %list_to_set(Entities, EntitiesUnique),
    %member(Entity, EntitiesUnique)
  %)).

%entity_head(Entity, [A,Type], _, TypeIri) :-
  %nonvar(Entity),
  %findall([A,Type,TypeIri], (
    %( entity_type([A,Type], TypeIri), rdfs_individual_of(Entity, TypeIri) );
    %[A,Type,TypeIri]=[a,thing,'http://www.ontologydesignpatterns.org/ont/dul/DUL.owl#Entity']
  %), Types),
  %member([A,Type,TypeIri], Types),
  %% pick only the most special types
  %forall( member([_,BType,BTypeIri], Types), (
    %BType = Type ; (
      %not(rdf_reachable(BTypeIri, rdfs:subClassOf, TypeIri))
    %)
  %)).


%%% Read entity namespace
%entity_ns(Entity, NamespaceUri, EntityName) :-
  %(  Entity =.. [':', NS, EntityName]
  %->  (
      %rdf_current_ns(NS, NamespaceUri)
  %) ; ( % fallback to knowrob namespace
      %EntityName = Entity,
      %rdf_current_ns(knowrob, NamespaceUri)
  %)), !.

%entity_ns(Entity, NamespaceUri, EntityName) :-
  %atom(Entity),
  %rdf_split_url(NamespaceUri, EntityName, Entity).


%%% Converts between IRI representation and description representation
%entity_iri(Iri, Descr, Formatter) :-
  %var(Descr),
  %rdf_split_url(NamespaceUri, Name, Iri),
  %rdf_current_ns(Namespace, NamespaceUri),
  %call(Formatter, NameUnderscore, Name),
  %(  Namespace=knowrob
  %-> Descr=NameUnderscore
  %;  Descr=Namespace:NameUnderscore
  %).

%entity_iri(Iri, Description, Formatter) :-
  %var(Iri),
  %entity_ns(Description, NS, NameUnderscore),
  %call(Formatter, NameUnderscore, Name),
  %atom_concat(NS, Name, Iri).

%entity_iri(Entity, Type) :-
  %rdf_has(Entity, rdf:type, Type),
  %rdf_split_url(Url, _, Type),
  %rdf_current_ns(NS, Url),
  %NS \= owl.

%entity_iri(Entity, Type) :-
  %rdfs_individual_of(Entity,Type).
