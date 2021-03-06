(** **********************************************************

Benedikt Ahrens, Ralph Matthes

SubstitutionSystems

2015


************************************************************)


(** **********************************************************

Contents :

- Definition of horizontal composition for natural transformations



************************************************************)



Require Import UniMath.Foundations.Basics.PartD.

Require Import UniMath.CategoryTheory.precategories.
Require Import UniMath.CategoryTheory.functor_categories.
Require Import UniMath.CategoryTheory.whiskering.
Require Import UniMath.CategoryTheory.PrecategoryBinProduct.
Require Import UniMath.CategoryTheory.UnicodeNotations.

Local Notation "F ⟶ G" := (nat_trans F G) (at level 39).
Local Notation "G □ F" := (functor_composite F G) (at level 35).
Local Notation "[ C , D , hs ]" := (functor_precategory C D hs).

Ltac pathvia b := (apply (@pathscomp0 _ _ b _ )).

Section horizontal_composition.

Variables C D E : precategory.

Variables F F' : functor C D.
Variables G G' : functor D E.

Variable α : F ⟶ F'.
Variable β : G ⟶ G'.

Lemma is_nat_trans_horcomp : is_nat_trans (G □ F) (G' □ F')
  (λ c : C, β (F c) ;; #G' (α _ )).
Proof.
  intros c d f; simpl.
  rewrite assoc.
  rewrite nat_trans_ax.
  repeat rewrite <- assoc; apply maponpaths.
  repeat rewrite <- functor_comp.
  rewrite nat_trans_ax; apply idpath.
Defined.

Definition hor_comp : nat_trans (G □ F) (G' □ F') := tpair _ _ is_nat_trans_horcomp.

End horizontal_composition.

Arguments hor_comp { _ _ _ } { _ _ _ _ } _ _ .

(*
Lemma horcomp_id_left (C D : precategory) (X : functor C C) (Z Z' : functor C D)(f : nat_trans Z Z')
  :
  hor_comp (nat_trans_id X) f = pre_whisker f.
*)
Lemma horcomp_id_left (C D : precategory) (X : functor C C) (Z Z' : functor C D)(f : nat_trans Z Z')
  :
  Π c : C, hor_comp (nat_trans_id X) f c = f (X c).
Proof.
  simpl.
  intro c.
  rewrite functor_id.
  rewrite id_right.
  apply idpath.
Qed.

Lemma horcomp_id_postwhisker (A B C : precategory)
   (hsB : has_homsets B) (hsC : has_homsets C) (X X' : [A, B, hsB]) (α : X --> X')
   (Z : [B ,C, hsC])
  : hor_comp α (nat_trans_id _ ) = post_whisker α Z.
Proof.
  apply nat_trans_eq.
  - apply hsC.
  - intro a.
    apply id_left.
Qed.

Definition functorial_composition_data (A B C : precategory) (hsB: has_homsets B) (hsC: has_homsets C) :
  functor_data (precategory_binproduct_data [A, B, hsB] [B, C, hsC])
               [A, C, hsC].
Proof.
  exists (fun FG => functor_composite (pr1 FG) (pr2 FG)).
  intros a b αβ.
  induction αβ as [α β].
  exact (hor_comp α β).
Defined.

Definition functorial_composition (A B C : precategory) (hsB: has_homsets B) (hsC: has_homsets C) :
  functor (precategory_binproduct [A, B, hsB] [B, C, hsC]) [A, C, hsC].
Proof.
  exists (functorial_composition_data A B C hsB hsC).
  split.
  - unfold functor_idax.
    intros FG.
    apply nat_trans_eq.
    apply hsC.
    intros x.
    apply remove_id_left.
    reflexivity.
    simpl.
    exact (functor_id (pr2 FG) ((pr1 (pr1 FG)) x)).
  - unfold functor_compax.
    intros FG1 FG2 FG3 αβ1 αβ2.
    induction αβ1 as [α1 β1].
    induction αβ2 as [α2 β2].

    apply nat_trans_eq.
    apply hsC.
    intros a.

    simpl.
    rewrite <- ?assoc.
    apply cancel_precomposition.
    rewrite (functor_comp _).
    rewrite -> ?assoc.
    apply cancel_postcomposition.
    apply pathsinv0.
    apply nat_trans_ax.
Defined.
