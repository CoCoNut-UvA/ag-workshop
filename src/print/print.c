/**
 * @file
 *
 * This file contains the code for the Print traversal.
 * The traversal has the uid: PRT
 *
 *
 */
#include <stdio.h>

#include "ccn/ccn.h"
#include "ccngen/ast.h"
#include "ccngen/enum.h"
#include "ccngen/trav.h"
#include "ccngen/trav_data.h"
#include "palm/dbug.h"

void PRTinit() { return; }
void PRTfini() { return; }

#define INDENT (DATA_PRT_GET()->indent)
static const uint32_t indent_size = 2;

/**
 * @fn PRTget_type
 */
static inline const char *PRTget_type(enum BasicType type) {
    switch (type) {
    case BT_bool:
        return "bool";
    case BT_int:
        return "int";
    case BT_string:
        return "string";
    default:
        return "unknown";
    }
}

static inline void PRTindent() {
    if (INDENT) {
        printf("%*c", INDENT * indent_size, ' ');
    }
}

/**
 * @fn PRTprogram
 */
node_st *PRTprogram(node_st *node) {
    TRAVstmts(node);
    return node;
}

/**
 * @fn PRTstmts
 */
node_st *PRTstmts(node_st *node) {
    TRAVstmt(node);
    TRAVnext(node);
    return node;
}

/**
 * @fn PRTfundef
 */
node_st *PRTfundef(node_st *node) {
    PRTindent();
    printf("%s %s() {\n", PRTget_type(FUNDEF_TYPE(node)), FUNDEF_NAME(node));
    INDENT++;
    TRAVbody(node);
    INDENT--;
    PRTindent();
    printf("}\n\n");

    return node;
}

/**
 * @fn PRTassign
 */
node_st *PRTassign(node_st *node) {
    PRTindent();
    if (ASSIGN_LET(node) != NULL) {
        printf("%s ", PRTget_type(ASSIGN_TYPE(node)));
        TRAVlet(node);
        printf(" = ");
    }

    TRAVexpr(node);
    printf(";\n");

    return node;
}

/**
 * @fn PRTreturn
 */
node_st *PRTreturn(node_st *node) {
    PRTindent();
    printf("return ");
    TRAVexpr(node);
    printf(";\n");

    return node;
}

/**
 * @fn PRTbinop
 */
node_st *PRTbinop(node_st *node) {
    char *tmp = NULL;
    printf("(");

    TRAVleft(node);

    switch (BINOP_OP(node)) {
    case BO_add:
        tmp = "+";
        break;
    case BO_sub:
        tmp = "-";
        break;
    case BO_mul:
        tmp = "*";
        break;
    case BO_div:
        tmp = "/";
        break;
    case BO_mod:
        tmp = "%";
        break;
    case BO_NULL:
        DBUG_ASSERT(false, "unknown binop detected!");
    }

    printf(" %s ", tmp);

    TRAVright(node);

    printf(")");
    printf("<type: %s>", PRTget_type(EXPR_TYPE(node)));

    return node;
}

/**
 * @fn PRTvarlet
 */
node_st *PRTvarlet(node_st *node) {
    printf("%s", VARLET_NAME(node));
    return node;
}

/**
 * @fn PRTvar
 */
node_st *PRTvar(node_st *node) {
    printf("%s", VAR_NAME(node));
    printf("<type: %s>", PRTget_type(EXPR_TYPE(node)));
    return node;
}

/**
 * @fn PRTfuncall
 */
node_st *PRTfuncall(node_st *node) {
    printf("%s()", FUNCALL_NAME(node));
    printf("<type: %s>", PRTget_type(EXPR_TYPE(node)));
    return node;
}

/**
 * @fn PRTnum
 */
node_st *PRTnum(node_st *node) {
    printf("%d", NUM_VAL(node));
    printf("<type: %s>", PRTget_type(EXPR_TYPE(node)));
    return node;
}

/**
 * @fn PRTstring
 */
node_st *PRTstring(node_st *node) {
    printf("\"%s\"", STRING_VAL(node));
    printf("<type: %s>", PRTget_type(EXPR_TYPE(node)));
    return node;
}

/**
 * @fn PRTbool
 */
node_st *PRTbool(node_st *node) {
    char *bool_str = BOOL_VAL(node) ? "true" : "false";
    printf("%s", bool_str);
    printf("<type: %s>", PRTget_type(EXPR_TYPE(node)));
    return node;
}
