/**
 * @file
 *
 * Traversal: checkError
 * UID      : CE
 *
 *
 */

#include "ccn/ccn.h"
#include "ccngen/ag.h"
#include "ccngen/ast.h"
#include "ccngen/trav.h"

#include "palm/ctinfo.h"

/**
 * @fn CEprogram
 */
node_st *CEprogram(node_st *node)
{
    CCNevaluateAttributes(node);

    if (PROGRAM_ERROR(node)) {
        CTI(CTI_ERROR, true, "Error in type checking.");
        CTIabortCompilation();
    }

    return node;
}
