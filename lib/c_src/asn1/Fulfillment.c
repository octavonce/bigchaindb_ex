/*
 * Generated by asn1c-0.9.29 (http://lionet.info/asn1c)
 * From ASN.1 module "Fulfillments"
 * 	found in "Fulfillments.asn"
 * 	`asn1c -fcompound-names`
 */

#include "Fulfillment.h"

static asn_oer_constraints_t asn_OER_type_Fulfillment_constr_1 CC_NOTUSED = {
	{ 0, 0 },
	-1};
asn_per_constraints_t asn_PER_type_Fulfillment_constr_1 CC_NOTUSED = {
	{ APC_CONSTRAINED,	 3,  3,  0,  4 }	/* (0..4) */,
	{ APC_UNCONSTRAINED,	-1, -1,  0,  0 },
	0, 0	/* No PER value map */
};
asn_TYPE_member_t asn_MBR_Fulfillment_1[] = {
	{ ATF_NOFLAGS, 0, offsetof(struct Fulfillment, choice.preimageSha256),
		(ASN_TAG_CLASS_CONTEXT | (0 << 2)),
		-1,	/* IMPLICIT tag at current level */
		&asn_DEF_PreimageFulfillment,
		0,
		{ 0, 0, 0 },
		0, 0, /* No default value */
		"preimageSha256"
		},
	{ ATF_POINTER, 0, offsetof(struct Fulfillment, choice.prefixSha256),
		(ASN_TAG_CLASS_CONTEXT | (1 << 2)),
		-1,	/* IMPLICIT tag at current level */
		&asn_DEF_PrefixFulfillment,
		0,
		{ 0, 0, 0 },
		0, 0, /* No default value */
		"prefixSha256"
		},
	{ ATF_POINTER, 0, offsetof(struct Fulfillment, choice.thresholdSha256),
		(ASN_TAG_CLASS_CONTEXT | (2 << 2)),
		-1,	/* IMPLICIT tag at current level */
		&asn_DEF_ThresholdFulfillment,
		0,
		{ 0, 0, 0 },
		0, 0, /* No default value */
		"thresholdSha256"
		},
	{ ATF_NOFLAGS, 0, offsetof(struct Fulfillment, choice.rsaSha256),
		(ASN_TAG_CLASS_CONTEXT | (3 << 2)),
		-1,	/* IMPLICIT tag at current level */
		&asn_DEF_RsaSha256Fulfillment,
		0,
		{ 0, 0, 0 },
		0, 0, /* No default value */
		"rsaSha256"
		},
	{ ATF_NOFLAGS, 0, offsetof(struct Fulfillment, choice.ed25519Sha256),
		(ASN_TAG_CLASS_CONTEXT | (4 << 2)),
		-1,	/* IMPLICIT tag at current level */
		&asn_DEF_Ed25519Sha512Fulfillment,
		0,
		{ 0, 0, 0 },
		0, 0, /* No default value */
		"ed25519Sha256"
		},
};
static const asn_TYPE_tag2member_t asn_MAP_Fulfillment_tag2el_1[] = {
    { (ASN_TAG_CLASS_CONTEXT | (0 << 2)), 0, 0, 0 }, /* preimageSha256 */
    { (ASN_TAG_CLASS_CONTEXT | (1 << 2)), 1, 0, 0 }, /* prefixSha256 */
    { (ASN_TAG_CLASS_CONTEXT | (2 << 2)), 2, 0, 0 }, /* thresholdSha256 */
    { (ASN_TAG_CLASS_CONTEXT | (3 << 2)), 3, 0, 0 }, /* rsaSha256 */
    { (ASN_TAG_CLASS_CONTEXT | (4 << 2)), 4, 0, 0 } /* ed25519Sha256 */
};
asn_CHOICE_specifics_t asn_SPC_Fulfillment_specs_1 = {
	sizeof(struct Fulfillment),
	offsetof(struct Fulfillment, _asn_ctx),
	offsetof(struct Fulfillment, present),
	sizeof(((struct Fulfillment *)0)->present),
	asn_MAP_Fulfillment_tag2el_1,
	5,	/* Count of tags in the map */
	0, 0,
	-1	/* Extensions start */
};
asn_TYPE_descriptor_t asn_DEF_Fulfillment = {
	"Fulfillment",
	"Fulfillment",
	&asn_OP_CHOICE,
	0,	/* No effective tags (pointer) */
	0,	/* No effective tags (count) */
	0,	/* No tags (pointer) */
	0,	/* No tags (count) */
	{ &asn_OER_type_Fulfillment_constr_1, &asn_PER_type_Fulfillment_constr_1, CHOICE_constraint },
	asn_MBR_Fulfillment_1,
	5,	/* Elements count */
	&asn_SPC_Fulfillment_specs_1	/* Additional specs */
};
