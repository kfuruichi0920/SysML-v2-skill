package <PackageName> {

    // Source
    // document_id: <DOC-ID>
    // section_scope: <SECTION>
    // assumptions: <ASSUMPTIONS>
    // review_points: <REVIEW-POINTS>

    requirement def RequirementItem {
        doc /* requirement definition placeholder */
    }

    constraint def ConstraintItem {
        doc /* constraint definition placeholder */
    }

    item def DomainItem;

    part def LogicalComponent {
        // PIM-oriented logical responsibility
    }

    interface def LogicalInterface {
        // semantic / logical interface
    }

    action def LogicalAction {
        // behavior extracted from source text
    }

    state def LogicalState {
        // state candidates if needed
    }

    part def RuntimeComponent {
        // PSM-oriented runtime realization
    }

    interface def RuntimeInterface {
        // runtime / execution interface
    }

    requirement <RequirementId> : RequirementItem {
        doc /* original requirement summary */
    }

    // Example trace placeholders
    // satisfy <RuntimeOrLogicalElement> -> <RequirementId>;
    // refine <LogicalElement> -> <RequirementId>;
    // allocate <RuntimeComponent> to <LogicalComponent>;
    // dependency from <ElementA> to <ElementB>;
}
