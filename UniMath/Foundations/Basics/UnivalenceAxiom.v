(** The univalence axiom and its consequences *)

(**

In this file, we formulate univalence and its consequences, including functional
extensionality (the statement that functions with equal values are equal).

One approach would be to take univalence as the only axiom and to formulate
theorems proving the consequences, whose proofs would appeal to the
univalence axiom.  We adopt a different approach here, preferring also to
introduce axioms for various consequences of univalence.  This allows us to
measure how subsequent theorems depend on the axioms using the "Print
Assumptions" command of Coq.

An important point is that the types of all our axioms are propositions, that is
types of h-level 1 and once an element of such a type is declared or contructed
it becomes a contractible type.

In particular, the declared element corresponding to the axiom and the element
that can be contructed using another, stronger, axiom are connected by a path.

Proofs that the types of our axioms are propositions will be provided in the
file UnivalenceAxiom2.

We postpone stating the axioms themselves until after all the implications
are established; this helps us encourage the use of the axioms for the
consequences of univalence, rather than the theorems giving the implications.

*)

(** Preliminaries  *)

Require Export UniMath.Foundations.Basics.PartB.

(* everything related to eta correction is obsolete *)

Definition eqweqmap { T1 T2 : UU } : T1 = T2 -> T1 ≃ T2.
Proof. intro e. induction e. apply idweq. Defined.

Definition toforallpaths { T : UU } (P:T -> UU) (f g :Π t:T, P t) : f = g -> f ~ g.
Proof. intros h t. induction h.  apply (idpath _). Defined.

Definition sectohfiber { X : UU } (P:X -> UU): (Π x:X, P x) -> (hfiber (fun f:_ => fun x:_ => pr1  (f x)) (fun x:X => x)) := (fun a : Π x:X, P x => tpair _ (fun x:_ => tpair _ x (a x)) (idpath (fun x:X => x))).

Definition hfibertosec { X : UU } (P:X -> UU):
  (hfiber (fun f x => pr1 (f x)) (fun x:X => x)) -> (Π x:X, P x)
  := fun se:_  => fun x:X => match se as se' return P x with tpair _ s e => (transportf P (toforallpaths _ (fun x:X => pr1 (s x)) (fun x:X => x) e x) (pr2  (s x))) end.

Definition sectohfibertosec { X : UU } (P:X -> UU):
  Π a : (Π x:X, P x), hfibertosec _ (sectohfiber _ a) = a.
Proof.
  reflexivity.
Defined.

Lemma isweqtransportf10 { X : UU } ( P : X -> UU ) { x x' : X } ( e :  paths x x' ) : isweq ( transportf P e ).
Proof. intros. destruct e.  apply idisweq. Defined.

Lemma isweqtransportb10 { X : UU } ( P : X -> UU ) { x x' : X } ( e :  paths x x' ) : isweq ( transportb P e ).
Proof. intros. apply ( isweqtransportf10 _ ( pathsinv0 e ) ). Defined.

Lemma l1  { X0 X0' : UU } ( ee : paths X0 X0' ) ( P : UU -> UU ) ( pp' : P X0' ) ( R : Π X X' : UU , Π w : weq X X' , P X' -> P X ) ( r : Π X : UU , Π p : P X , paths ( R X X ( idweq X ) p ) p ) : paths ( R X0 X0' ( eqweqmap ee ) pp' ) (  transportb P ee pp' ).
Proof. destruct ee. simpl. apply r. Defined.

(** Axiom statements (propositions) *)

Definition univalenceStatement := Π X Y:UU, isweq (@eqweqmap X Y).

Definition funextemptyStatement := Π (X:UU) (f g : X->empty), f = g.

Definition propositionalUnivalenceStatement :=
  Π (P Q:UU), isaprop P -> isaprop Q -> (P -> Q) -> (Q -> P) -> P=Q.

Definition funcontrStatement :=
  Π (X : UU) (P:X -> UU),
    (Π x:X, iscontr (P x)) -> iscontr (Π x:X, P x).

Definition funextcontrStatement :=
  Π (T:UU) (P:T -> UU) (g: Π t, P t), ∃! (f:Π t, P t), Π t:T, f t = g t.

Definition isweqtoforallpathsStatement :=
  Π (T:UU) (P:T -> UU) (f g :Π t:T, P t), isweq (toforallpaths _ f g).

(** Axiom consequence statements (not propositions) *)

Definition funextsecStatement :=
  Π (T:UU) (P:T -> UU) (f g :Π t:T, P t), f ~ g -> f = g.

Definition funextfunStatement :=
  Π (X Y:UU) (f g : X -> Y), f ~ g -> f = g.

Definition weqtopathsStatement := Π ( T1 T2 : UU ), T1 ≃ T2 -> T1 = T2.

Definition weqpathsweqStatement (weqtopaths:weqtopathsStatement) :=
  Π ( T1 T2 : UU ) ( w : T1 ≃ T2 ), eqweqmap (weqtopaths _ _ w) = w.

Definition weqtoforallpathsStatement :=
  Π (T:UU) (P:T -> UU) (f g :Π t:T, P t), (f = g) ≃ (f ~ g).

(** Implications between statements and consequences of them *)

Theorem funextsecImplication : isweqtoforallpathsStatement -> funextsecStatement.
Proof.
  intros fe ? ? ? ?. exact (invmap (weqpair _ (fe _ _ f g))).
Defined.

Theorem funextfunImplication : funextsecStatement -> funextfunStatement.
Proof.
  intros fe ? ?. apply fe.
Defined.

(** We show that [ univalenceAxiom ] is equivalent to the axioms [ weqtopathsStatement ] and [ weqpathsweqStatement ] stated below . *)

Theorem univfromtwoaxioms :
  (Σ weqtopaths: weqtopathsStatement, weqpathsweqStatement weqtopaths)
  <-> univalenceStatement.
Proof.
  split.
  { intros [weqtopaths weqpathsweq] T1 T2.
    set ( P1 := fun XY : UU × UU => pr1 XY = pr2 XY ) .
    set ( P2 := fun XY :  UU × UU => weq (pr1 XY)  (pr2 XY) ) .
    set ( Z1 := total2 P1 ). set ( Z2 := total2 P2 ).
    set ( f := totalfun _ _ ( fun XY : UU × UU =>  @eqweqmap (pr1 XY) (pr2 XY)) : Z1 -> Z2 ) .
    set ( g := totalfun _ _ ( fun XY : UU × UU =>  weqtopaths (pr1 XY) (pr2 XY) ) : Z2 -> Z1 ) .
    assert (efg : funcomp g f ~ idfun _) .
    - intro z2 . induction z2 as [ XY e ] .
      unfold funcomp . unfold idfun . unfold g . unfold f . unfold totalfun . simpl .
      apply ( maponpaths ( fun w : weq ( pr1 XY) (pr2 XY) =>  tpair P2 XY w )
                       ( weqpathsweq ( pr1 XY ) ( pr2 XY ) e )) .
    - set ( h := fun a1 : Z1 =>  pr1 ( pr1 a1 ) ) .
      assert ( egf0 : Π a1 : Z1 ,  pr1 ( g ( f a1 ) ) = pr1 a1 ).
      + intro. apply idpath.
      + assert ( egf1 : Π a1 a1' : Z1 ,  paths ( pr1 a1' ) (  pr1 a1 ) ->  paths a1' a1 ).
        * intros.
          set ( X' :=  maponpaths pr1 X ).
          assert ( is : isweq h ).
          { simpl in h .  apply isweqpr1pr1 . }
          apply ( invmaponpathsweq ( weqpair h is ) _ _ X' ).
        * set ( egf := fun a1  => egf1 _ _ ( egf0 a1 ) ).
          set ( is2 := gradth _ _ egf efg ).
          apply ( isweqtotaltofib _ _ ( fun _ => eqweqmap) is2 ( dirprodpair T1 T2 ) ).
          }
  { intros ua.
    simple refine (_,,_).
    - intros ? ?. exact (invmap (weqpair _ (ua _ _))).
    - intros ? ?. exact (homotweqinvweq (weqpair _ (ua _ _))). }
Defined.

(** Conjecture :  the pair [weqtopaths] and [weqtopathsweq] in the proof above is well defined up to a canonical equality. **)

Section UnivalenceImplications.

  (** In this section we take univalence as a hypothesis, not as an axiom, so
     we can limit the number of theorems that take univalence an axiom.

     The suffix UAH on the name of a theorem indicates a theorem that will be
     stated later unconditionally, with a proof that appeals to the future
     univalence axiom. *)

  Hypothesis univalenceAxiom : univalenceStatement.

  Theorem univalenceUAH (X Y:UU) : (X=Y) ≃ (X≃Y).
  Proof. exact (weqpair _ (univalenceAxiom X Y)). Defined.

  Definition weqtopathsUAH : weqtopathsStatement.
  Proof.
    intros ? ?. exact (invmap (univalenceUAH _ _)).
  Defined.
  Arguments weqtopathsUAH {_ _} _.

  Definition weqpathsweqUAH : weqpathsweqStatement (@weqtopathsUAH).
  Proof.
    intros ? ? w. exact (homotweqinvweq (univalenceUAH T1 T2) w).
  Defined.
  Arguments weqpathsweqUAH {_ _} _.

  Lemma propositionalUnivalenceUAH: propositionalUnivalenceStatement.
  Proof.
    unfold propositionalUnivalenceStatement; intros ? ? i j f g.
    apply weqtopathsUAH.
    simple refine (weqpair f (gradth f g _ _)).
    - intro p. apply proofirrelevance, i.
    - intro q. apply proofirrelevance, j.
  Defined.

  (** ** Proof of the functional extensionality for functions from univalence *)

  (** ** Transport theorem.

    Theorem saying that any general scheme to "transport" a structure along a
    weak equivalence which does not change the structure in the case of the
    identity equivalence is equivalent to the transport along the path which
    corresponds to a weak equivalence by the univalenceAxiom. As a corollary we
    conclude that for any such transport scheme the corresponding maps on spaces
    of structures are weak equivalences. *)

  Theorem weqtransportbUAH ( P : UU -> UU )
          ( R : Π ( X X' : UU ) ( w :  weq X X' ) , P X' -> P X )
          ( r : Π X : UU , Π p : P X , R X X ( idweq X ) p = p ) :
    Π ( X X' : UU ) ( w :  weq X X' ) ( p' : P X' ),
      R X X' w p' = transportb P ( weqtopathsUAH w ) p'.
  Proof.
    intros.
    set ( uv := weqtopathsUAH w ).
    set ( v := eqweqmap uv ).
    assert ( e : v = w ) .
    - unfold weqtopathsUAH in uv.
      apply ( homotweqinvweq ( univalenceUAH X X' ) w ).
    - assert ( ee : R X X' v p' = R X X' w p' ).
      + set ( R' := fun vis : X ≃ X' => R X X' vis p' ).
        assert ( ee' : R' v = R' w ).
        * apply (  maponpaths R' e ).
        * assumption.
      + destruct ee. now apply l1.
  Defined.

  Corollary isweqweqtransportbUAH
            ( P : UU -> UU )
            ( R :  Π ( X X' : UU ) ( w : X ≃ X' ) , P X' -> P X )
            ( r :  Π X : UU , Π p : P X , R X X ( idweq X ) p  = p ) :
    Π ( X X' : UU ) ( w : X ≃ X' ),
      isweq ( fun p' :  P X' => R X X' w p' ).
  Proof.
    intros.
    assert ( e : R X X' w ~ transportb P ( weqtopathsUAH w )).
    - unfold homot. now apply weqtransportbUAH.
    - assert ( ee : transportb P ( weqtopathsUAH w ) ~ R X X' w).
      + intro p'. apply ( pathsinv0 ( e p' ) ).
      + clear e.
        assert ( is1 : isweq ( transportb P ( weqtopathsUAH w ) ) ).
        apply isweqtransportb10.
        apply ( isweqhomot ( transportb P ( weqtopathsUAH w ) ) (R X X' w) ee is1 ).
  Defined.

  (** Theorem saying that composition with a weak equivalence is a weak equivalence on function spaces. *)

  Theorem isweqcompwithweqUAH { X X' : UU } ( w : weq X X' ) ( Y : UU ) :
    isweq ( fun f : X' -> Y => ( fun x : X => f ( w x ) ) ).
  Proof.
    set ( P := fun X0 : UU => ( X0 -> Y ) ).
    set ( R := fun X0 : UU => ( fun X0' : UU => ( fun w1 : X0 -> X0' =>  ( fun  f : P X0'  => ( fun x : X0 => f ( w1 x ) ) ) ) ) ).
    apply ( isweqweqtransportbUAH P R (fun X0 f => idpath _) X X' w ).
  Defined.

  Lemma eqcor0UAH { X X' : UU } ( w :  weq X X' ) ( Y : UU ) ( f1 f2 : X' -> Y ) :
    (fun x : X => f1 ( w x )) = (fun x : X => f2 ( w x ) ) -> f1 = f2.
  Proof. apply ( invmaponpathsweq ( weqpair _ ( isweqcompwithweqUAH w Y ) ) f1 f2 ). Defined.

  Lemma apathpr1toprUAH ( T : UU ) : paths ( fun z :  pathsspace T => pr1 z ) ( fun z : pathsspace T => pr1 ( pr2 z ) ).
  Proof. apply ( eqcor0UAH ( weqpair _ ( isweqdeltap T ) ) _ ( fun z :  pathsspace T => pr1 z ) ( fun z :  pathsspace T => pr1 ( pr2 z ) ) ( idpath ( idfun T ) ) ) . Defined.

  Theorem funextfunPreliminaryUAH : funextfunStatement.
  Proof.
    intros ? ? f1 f2 e.
    set ( f := fun x : X => pathsspacetriple Y ( e x ) ).
    set ( g1 := fun z : pathsspace Y => pr1 z ).
    set ( g2 := fun z : pathsspace Y => pr1 ( pr2 z ) ).
    change ( (funcomp f g1) = (funcomp f g2) ).
    apply maponpaths.
    apply apathpr1toprUAH.
  Defined.
  Arguments funextfunPreliminaryUAH {_ _} _ _ _.

  Lemma funextemptyUAH : funextemptyStatement.
  Proof.
    unfold funextemptyStatement; intros.
    apply funextfunPreliminaryUAH.
    intro x.
    induction (f x).
  Defined.

  (** *** Deduction of functional extensionality for dependent functions (sections) from functional extensionality of usual functions *)

  Lemma isweqlcompwithweqUAH {X X' : UU} (w: weq X X') (Y:UU) : isweq (fun (a:X'->Y) x => a (w x)).
  (* this lemma is currently unused *)
  Proof.
    simple refine (gradth _ _ _ _).
    exact (fun b x' => b (invweq w x')).
    exact (fun a => funextfunPreliminaryUAH _ a (fun x' => maponpaths a (homotweqinvweq w x'))).
    exact (fun a => funextfunPreliminaryUAH _ a (fun x  => maponpaths a (homotinvweqweq w x ))).
  Defined.

  Lemma isweqrcompwithweqUAH { Y Y':UU } (w: weq Y Y')(X:UU) :
    isweq (fun a:X->Y => (fun x => w (a x))).
  Proof.
    simple refine (gradth _ _ _ _).
    exact (fun a':X->Y' => fun x => (invweq  w (a' x))).
    exact (fun a :X->Y  => funextfunPreliminaryUAH _ a (fun x => homotinvweqweq w (a x))).
    exact (fun a':X->Y' => funextfunPreliminaryUAH _ a' (fun x => homotweqinvweq w (a' x))).
  Defined.

  Theorem funcontrUAH : funcontrStatement.
  Proof.
    unfold funcontrStatement.
    intros ? ? X0.
    set (T1 := Π x:X, P x).
    set (T2 := (hfiber (fun f: (X -> total2 P)  => fun x: X => pr1  (f x)) (fun x:X => x))).
    assert (is1:isweq (@pr1 X P)).
    - apply isweqpr1. assumption.
    - set (w1:= weqpair  (@pr1 X P) is1).
      assert (X1:iscontr T2).
      + apply (isweqrcompwithweqUAH w1 X (fun x:X => x)).
      + apply (iscontrretract _ _ (sectohfibertosec P) X1).
  Defined.

  (** Proof of the fact that the [ toforallpaths ] from [paths s1 s2] to
  [Π t:T, paths (s1 t) (s2 t)] is a weak equivalence - a strong form of
  functional extensionality for sections of general families. The proof uses
  only [funcontrUAH] which is an element of a proposition.  *)

  Lemma funextcontrUAH : funextcontrStatement.
  Proof.
    unfold funextcontrStatement.
    intros.
    unshelve refine (iscontrretract (X := Π t, Σ p, p = g t) _ _ _ _).
    - intros x. unshelve refine (_,,_).
      + intro t. exact (pr1 (x t)).
      + intro t; simpl. exact (pr2 (x t)).
    - intros y t. exists (pr1 y t). exact (pr2 y t).
    - intros u. induction u as [t x]. reflexivity.
    - apply funcontrUAH. intro t. apply iscontrcoconustot.
  Defined.
  Arguments funextcontrUAH {_} _ _.

  Theorem isweqtoforallpathsUAH : isweqtoforallpathsStatement.
  Proof.
    unfold isweqtoforallpathsStatement.
    intros.
    refine (isweqtotaltofib _ _ (λ (h:Π t, P t), toforallpaths _ h g) _ f).
    refine (isweqcontrcontr (X := Σ (h: Π t, P t), h = g)
              (λ ff, tpair _ (pr1 ff) (toforallpaths P (pr1 ff) g (pr2 ff))) _ _).
    { exact (iscontrcoconustot _ g). }
    { apply funextcontrUAH. }
  Qed.

End UnivalenceImplications.

(** Univalence implies each of the other axioms *)

Definition funcontrFromUnivalence: univalenceStatement -> funcontrStatement
  := funcontrUAH.

Definition funextsecweqFromUnivalence: univalenceStatement -> isweqtoforallpathsStatement
  := isweqtoforallpathsUAH.

Definition funextemptyFromUnivalence: univalenceStatement -> funextemptyStatement
  := funextemptyUAH.

Definition propositionalUnivalenceFromUnivalence: univalenceStatement -> propositionalUnivalenceStatement
  := propositionalUnivalenceUAH.

Definition funextcontrStatementFromUnivalence: univalenceStatement ->  funextcontrStatement
  := funextcontrUAH.

(** the axioms themselves *)

Axiom univalenceAxiom : univalenceStatement.
Axiom funextemptyAxiom : funextemptyStatement.
Axiom isweqtoforallpathsAxiom : isweqtoforallpathsStatement.
Axiom funcontrAxiom : funcontrStatement.
Axiom propositionalUnivalenceAxiom : propositionalUnivalenceStatement.
Axiom funextcontrAxiom : funextcontrStatement.

(** provide some theorems based on the axioms  *)

Definition funextempty := funextemptyAxiom.

Definition univalence := univalenceUAH univalenceAxiom.

Definition weqtopaths : weqtopathsStatement.
Proof.
  unfold weqtopathsStatement.
  intros ? ?.
  exact (invmap (univalence _ _)).
Defined.
Arguments weqtopaths {_ _} _.

Definition weqpathsweq := weqpathsweqUAH univalenceAxiom.
Arguments weqpathsweq {_ _} _.

Definition funcontr : funcontrStatement := funcontrAxiom.
Arguments funcontr {_} _ _.

Definition funextcontr : funextcontrStatement := @funextcontrAxiom.
Arguments funextcontr {_} _ _.

Definition isweqtoforallpaths : isweqtoforallpathsStatement := isweqtoforallpathsAxiom.
Arguments isweqtoforallpaths {_} _ _ _ _.

Definition weqtoforallpaths : weqtoforallpathsStatement
  := λ X P f g, weqpair _ (@isweqtoforallpaths X P f g).
Arguments weqtoforallpaths {_} _ _ _.
(* Print Assumptions weqtoforallpaths. (* isweqtoforallpathsAxiom *) *)

Definition funextsec : funextsecStatement := funextsecImplication isweqtoforallpathsAxiom.
Arguments funextsec {_} _ _ _ _.
(* Print Assumptions funextsec.    (* isweqtoforallpathsAxiom *) *)

Definition funextfun := funextfunImplication (@funextsec).
Arguments funextfun {_ _} _ _ _.
(* Print Assumptions funextfun.    (* isweqtoforallpathsAxiom *) *)

Definition weqfunextsec { T : UU } (P:T -> UU) (f g : Π t:T, P t) :
  (f ~ g) ≃ (f = g)
  := invweq (weqtoforallpaths P f g).
(* Print Assumptions weqfunextsec. (* isweqtoforallpathsAxiom *) *)

Corollary funcontrtwice { X : UU } (P: X-> X -> UU) (is: Π (x x':X), iscontr (P x x')) :
  iscontr (Π (x x':X), P x x').
Proof.
  intros.
  assert (is1: Π x:X, iscontr (Π x':X, P x x')).
  - intro. apply (funcontr _ (is x)).
  - apply (funcontr _ is1).
Defined.

(** Check assumptions *)
