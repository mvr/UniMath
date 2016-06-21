Require Import UniMath.Foundations.Basics.PartD.
Require Import UniMath.CategoryTheory.precategories.
Require Import UniMath.CategoryTheory.functor_categories.
Require Import UniMath.CategoryTheory.ProductPrecategory.
Require Import UniMath.CategoryTheory.HorizontalComposition.
Require Import UniMath.CategoryTheory.equivalences.

Arguments functor_composite {_ _ _} _ _ .

(******************************************************************************)
(* Definition of a prebicategory *)

Local Notation "C c× D" := (product_precategory C D) (at level 75, right associativity).

Local Notation "a -2-> b" := (precategory_morphisms a b)(at level 50).
(* To keep it straight in my head *)
Local Notation "alpha ;v; beta" := (compose alpha beta) (at level 50, format "alpha ;v; beta", no associativity).

Definition prebicategory_ob_1mor_2mor :=
  total2 (fun C : UU => forall a b : C, precategory).

Definition bicat_ob (C : prebicategory_ob_1mor_2mor) : UU := @pr1 _ _ C.
Coercion bicat_ob : prebicategory_ob_1mor_2mor >-> UU.

Definition homprecat {C : prebicategory_ob_1mor_2mor} (a b : C) : precategory :=
  (pr2 C) a b.

Local Notation "a -1-> b" := (homprecat a b)(at level 50).

Definition prebicategory_id_comp :=
  total2 ( fun C : prebicategory_ob_1mor_2mor =>
    dirprod (forall a : C, a -1-> a)
            (forall a b c : C, functor ((a -1-> b) c× (b -1-> c)) (a -1-> c))).

Definition prebicategory_ob_1mor_2mor_from_prebicategory_id_comp (C : prebicategory_id_comp) :
  prebicategory_ob_1mor_2mor := pr1 C.
Coercion prebicategory_ob_1mor_2mor_from_prebicategory_id_comp :
  prebicategory_id_comp >-> prebicategory_ob_1mor_2mor.

Definition identity_1mor {C : prebicategory_id_comp} (a : C) : a -1-> a
  := pr1 (pr2 C) a.

Definition idto1mor {C : prebicategory_id_comp} { a b : C }
  (p : a = b)
  : a -1-> b.
Proof.
  induction p.
  apply identity_1mor.
Defined.

Definition identity_2mor {C : prebicategory_id_comp} {a b : C} (f : a -1-> b)
  := identity f.

Definition compose_functor {C : prebicategory_id_comp} (a b c : C) :
  functor ((a -1-> b) c× (b -1-> c)) (a -1-> c)
  := pr2 (pr2 C) a b c.

Definition compose_1mor {C : prebicategory_id_comp} {a b c : C} (f : a -1-> b) (g : b -1-> c)
  := functor_on_objects (compose_functor a b c) (dirprodpair f g).

Local Notation "f ;1; g" := (compose_1mor f g) (at level 50, format "f ;1; g", no associativity).

Definition compose_2mor_horizontal {C : prebicategory_id_comp} {a b c : C}
           { f f' : a -1-> b } { g g' : b -1-> c }
           ( alpha : f -2-> f' ) ( beta : g -2-> g' )
  : ( f ;1; g ) -2-> ( f' ;1; g' ).
Proof.
  apply functor_on_morphisms.
  unfold precategory_morphisms.
  simpl.
  exact (dirprodpair alpha beta).
Defined.

Local Notation "alpha ;h; beta" := (compose_2mor_horizontal alpha beta) (at level 50, format "alpha ;h; beta").
(* TODO: come up with a reasonable precedence for ;v; ;h; *)

Definition associator_trans { C : prebicategory_id_comp } (a b c d : C) :=
  nat_trans
    (functor_composite
      (product_functor (functor_identity _) (compose_functor b c d))
      (compose_functor a b d))
    (functor_composite
      (product_precategory_assoc _ _ _)
      (functor_composite
        (product_functor (compose_functor a b c) (functor_identity _))
        (compose_functor a c d))).

Definition left_unitor_trans { C : prebicategory_id_comp } (a b : C) :=
  nat_trans
    (functor_composite
      (pair_functor
        (functor_composite (unit_functor _) (ob_as_functor (identity_1mor a)))
        (functor_identity _))
      (compose_functor a a b))
    (functor_identity _).

Definition right_unitor_trans { C : prebicategory_id_comp } (a b : C) :=
  nat_trans
    (functor_composite
      (pair_functor
        (functor_identity _)
        (functor_composite (unit_functor _) (ob_as_functor (identity_1mor b))))
      (compose_functor a b b))
    (functor_identity _).

Definition prebicategory_data :=
  total2 (fun C : prebicategory_id_comp =>
    dirprod
      (forall a b c d : C, associator_trans a b c d)
      ( dirprod
        (forall a b : C, left_unitor_trans a b)
        (* Right *)
        (forall a b : C, right_unitor_trans a b)
      )).

Definition prebicategory_id_comp_from_prebicategory_data (C : prebicategory_data) :
     prebicategory_id_comp := pr1 C.
Coercion prebicategory_id_comp_from_prebicategory_data :
  prebicategory_data >-> prebicategory_id_comp.

Definition has_2mor_sets (C : prebicategory_data) :=
  forall a b : C,
  forall f g : a -1-> b,
    isaset (f -2-> g).

Definition associator_2mor {C : prebicategory_data} { a b c d : C }
           (f : a -1-> b)
           (g : b -1-> c)
           (h : c -1-> d)
  : (f ;1; (g ;1; h)) -2-> ((f ;1; g) ;1; h).
Proof.
  set (A := pr1 (pr2 C) a b c d).
  unfold associator_trans in A.
  exact (A (prodcatpair f (prodcatpair g h))).
Defined.

Definition left_unitor_2mor {C : prebicategory_data} { a b : C }
           (f : a -1-> b)
  : (identity_1mor a) ;1; f -2-> f.
Proof.
  set (A := pr1 (pr2 (pr2 C)) a b).
  unfold left_unitor_trans in A.
  exact (A f).
Defined.

Definition right_unitor_2mor {C : prebicategory_data} { a b : C }
           (f : a -1-> b)
  : f ;1; (identity_1mor b) -2-> f.
Proof.
  set (A := pr2 (pr2 (pr2 C)) a b).
  unfold right_unitor_trans in A.
  exact (A f).
Defined.

Definition associator_and_unitors_are_iso (C : prebicategory_data)
  :=   (forall a b c d : C,
        forall (f : a -1-> b)
          (g : b -1-> c)
          (h : c -1-> d), is_iso (associator_2mor f g h))
     × (forall a b : C,
        forall f : a -1-> b, is_iso (left_unitor_2mor f))
     × (forall a b : C,
        forall g : a -1-> b, is_iso (right_unitor_2mor g)).

Definition pentagon_axiom { C : prebicategory_data } { a b c d e : C }
  (k : a -1-> b)
  (h : b -1-> c)
  (g : c -1-> d)
  (f : d -1-> e)
  :=
    (* Anticlockwise *)
        (associator_2mor k h (g ;1; f))
    ;v; (associator_2mor (k ;1; h) g f)
   =
    (* Clockwise *)
        ((identity k) ;h; (associator_2mor h g f))
    ;v; (associator_2mor k (h ;1; g) f)
    ;v; ((associator_2mor k h g) ;h; (identity f))
  .

Definition triangle_axiom {C : prebicategory_data} { a b c : C }
           (f : a -1-> b)
           (g : b -1-> c)
  :=       ((identity_2mor f) ;h; (left_unitor_2mor g))
     =     (associator_2mor f (identity_1mor b) g)
       ;v; ((right_unitor_2mor f) ;h; (identity_2mor g)).

Definition prebicategory_coherence (C : prebicategory_data)
  := (forall a b c d e : C,
      forall k : a -1-> b,
      forall h : b -1-> c,
      forall g : c -1-> d,
      forall f : d -1-> e,
        pentagon_axiom k h g f)
     ×
     (forall a b c : C,
      forall f : a -1-> b,
      forall g : b -1-> c,
        triangle_axiom f g).

Definition is_prebicategory (C : prebicategory_data) :=
                (has_2mor_sets C)
              × (associator_and_unitors_are_iso C)
              × (prebicategory_coherence C).

Definition prebicategory := total2 is_prebicategory.

Definition prebicategory_data_from_prebicategory (C : prebicategory) :
       prebicategory_data := pr1 C.
Coercion prebicategory_data_from_prebicategory : prebicategory >-> prebicategory_data.

Definition prebicategory_has_2mor_sets {C : prebicategory} (a b : C)
  : has_homsets (a -1-> b)
  := (pr1 (pr2 C)) a b.

Definition associator {C : prebicategory} { a b c d : C }
           (f : a -1-> b)
           (g : b -1-> c)
           (h : c -1-> d)
  : iso (f ;1; (g ;1; h)) ((f ;1; g) ;1; h).
Proof.
  use tpair.
  - exact (associator_2mor _ _ _).
  - exact ((pr1 (pr1 (pr2 (pr2 C)))) a b c d f g h).
Defined.

Definition left_unitor {C : prebicategory} { a b : C }
           (f : a -1-> b)
  : iso ((identity_1mor a) ;1; f) f.
Proof.
  use tpair.
  - exact (left_unitor_2mor _).
  - exact ((pr1 (pr2 (pr1 (pr2 (pr2 C))))) a b f).
Defined.

Definition right_unitor {C : prebicategory} { a b : C }
           (f : a -1-> b)
  : iso (f ;1; (identity_1mor b)) f.
Proof.
  use tpair.
  - exact (right_unitor_2mor _).
  - exact ((pr2 (pr2 (pr1 (pr2 (pr2 C))))) a b f).
Defined.

(******************************************************************************)
(* Interchange Law *)

Lemma interchange {C : prebicategory} {a b c : C}
  {f1 f2 f3 : a -1-> b} {g1 g2 g3 : b -1-> c}
  (a1 : f1 -2-> f2) (a2 : f2 -2-> f3)
  (b1 : g1 -2-> g2) (b2 : g2 -2-> g3)
  : (a1 ;v; a2) ;h; (b1 ;v; b2) = (a1 ;h; b1) ;v; (a2 ;h; b2).
Proof.
  unfold compose_2mor_horizontal.
  unfold dirprodpair.
  assert (X : (prodcatmor a1 b1) ;v; (prodcatmor a2 b2) = (prodcatmor (a1;v;a2) (b1;v;b2))) by reflexivity.
  unfold prodcatmor in X.
  simpl in X. (* This has no visible effect on X, but rewrite doesn't work without it  *)
  rewrite <- X.
  apply functor_comp.
Qed.

(******************************************************************************)
(* Whiskering *)

Definition whisker_left {C : prebicategory} {a b c : C}
           (f : a -1-> b) {g h : b -1-> c} (alpha : g -2-> h)
  : (f ;1; g) -2-> (f ;1; h)
  := (identity_2mor f) ;h; alpha.

Definition whisker_left_iso {C : prebicategory} {a b c : C}
           (f : a -1-> b) {g h : b -1-> c} (alpha : iso g h)
  : iso (f ;1; g) (f ;1; h).
Proof.
  exists (whisker_left f alpha).
  fold (is_isomorphism (whisker_left f alpha)).
  unfold whisker_left.
  unfold compose_2mor_horizontal.
  set (i := prodcatiso (identity_iso f) alpha).
  apply (functor_on_iso_is_iso _ _ _ _ _ i).
Defined.

Definition whisker_left_on_comp {C : prebicategory} {a b c : C}
  (f : a -1-> b) {g h i : b -1-> c}
  (alpha : g -2-> h) (alpha' : h -2-> i)
  : whisker_left f (alpha ;v; alpha')
  = whisker_left f alpha ;v; whisker_left f alpha'.
Proof.
  unfold whisker_left.
  pathvia ((identity_2mor f;v; identity_2mor f);h;(alpha;v;alpha')).
  - rewrite id_left.
    reflexivity.
  - apply interchange.
Defined.

Definition whisker_right {C : prebicategory} {a b c : C}
  {f g : a -1-> b} (alpha : f -2-> g) (h : b -1-> c)
  : (f ;1; h) -2-> (g ;1; h)
  := alpha ;h; (identity_2mor h).

Definition whisker_right_iso {C : prebicategory} {a b c : C}
           {f g : a -1-> b} (alpha : iso f g) (h : b -1-> c)
  : iso (f ;1; h) (g ;1; h).
Proof.
  exists (whisker_right alpha h).
  fold (is_isomorphism (whisker_right alpha h)).
  unfold whisker_right.
  unfold compose_2mor_horizontal.
  set (i := prodcatiso alpha (identity_iso h)).
  apply (functor_on_iso_is_iso _ _ _ _ _ i).
Defined.

Definition whisker_right_on_comp {C : prebicategory} {a b c : C}
  {f g h : a -1-> b} (alpha : f -2-> g) (alpha' : g -2-> h) (i : b -1-> c)
  : whisker_right (alpha ;v; alpha') i
  = whisker_right alpha i ;v; whisker_right alpha' i.
Proof.
  unfold whisker_right.
  pathvia ((alpha;v;alpha');h;(identity_2mor i;v; identity_2mor i)).
  - rewrite id_left.
    reflexivity.
  - apply interchange.
Defined.