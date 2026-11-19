use claimsure_docs;

// Drop existing collection for a clean run
db.claim_investigations.drop();

// 1. CREATE: Insert claim documents with nested evidence & investigation notes
db.claim_investigations.insertMany([
  {
    claim_number: "CLM-00001",
    policy_number: "POL-00112",
    claim_type: "Accident",
    region: "North",
    outcome: "Approved",
    claim_amount: 19426.80,
    documents: [
      { doc_type: "Police FIR", verified: true, uploaded_at: new Date("2025-01-26") },
      { doc_type: "Repair Estimate", verified: true, uploaded_at: new Date("2025-01-27") }
    ],
    investigation_notes: [
      { investigator: "INV-101", note: "Spot inspection matches rear-end collision report.", risk_flag: "Low", date: new Date("2025-02-02") }
    ]
  },
  {
    claim_number: "CLM-00002",
    policy_number: "POL-00005",
    claim_type: "Medical",
    region: "East",
    outcome: "Rejected",
    claim_amount: 84032.63,
    documents: [
      { doc_type: "Hospital Bill", verified: false, uploaded_at: new Date("2026-09-01") }
    ],
    investigation_notes: [
      { investigator: "INV-104", note: "Policy expired prior to hospital admission date.", risk_flag: "High", date: new Date("2026-09-05") }
    ]
  },
  {
    claim_number: "CLM-00008",
    policy_number: "POL-00079",
    claim_type: "Accident",
    region: "West",
    outcome: "Settled",
    claim_amount: 48846.20,
    documents: [
      { doc_type: "Police FIR", verified: true, uploaded_at: new Date("2026-03-19") },
      { doc_type: "Discharge Summary", verified: true, uploaded_at: new Date("2026-03-21") }
    ],
    investigation_notes: [
      { investigator: "INV-102", note: "All bills verified with network hospital.", risk_flag: "Low", date: new Date("2026-03-25") }
    ]
  },
  {
    claim_number: "CLM-00013",
    policy_number: "POL-00132",
    claim_type: "Theft",
    region: "South",
    outcome: "Approved",
    claim_amount: 147706.48,
    documents: [
      { doc_type: "Police Untraced Report", verified: true, uploaded_at: new Date("2025-08-25") }
    ],
    investigation_notes: [
      { investigator: "INV-105", note: "CCTV footage confirmed theft from residential parking.", risk_flag: "Medium", date: new Date("2025-08-30") }
    ]
  },
  {
    claim_number: "CLM-00016",
    policy_number: "POL-00070",
    claim_type: "Damage",
    region: "East",
    outcome: "Rejected",
    claim_amount: 160730.82,
    documents: [
      { doc_type: "Surveyor Report", verified: true, uploaded_at: new Date("2026-04-06") }
    ],
    investigation_notes: [
      { investigator: "INV-101", note: "Pre-existing structural damage excluded under policy terms.", risk_flag: "High", date: new Date("2026-04-10") }
    ]
  },
  {
    claim_number: "CLM-00031",
    policy_number: "POL-00004",
    claim_type: "Medical",
    region: "South",
    outcome: "Settled",
    claim_amount: 170537.37,
    documents: [
      { doc_type: "Discharge Summary", verified: true, uploaded_at: new Date("2026-02-02") },
      { doc_type: "Pharmacy Invoices", verified: true, uploaded_at: new Date("2026-02-03") }
    ],
    investigation_notes: [
      { investigator: "INV-103", note: "Pre-authorisation approved; final audit clear.", risk_flag: "Low", date: new Date("2026-02-10") }
    ]
  }
]);

// 2. INDEXES: Optimize lookups and aggregation queries
db.claim_investigations.createIndex({ claim_number: 1 }, { unique: true });
db.claim_investigations.createIndex({ claim_type: 1, region: 1, outcome: 1 });

// 3. READ: Query all high-risk flagged claims
print("--- High Risk Investigations ---");
db.claim_investigations.find({ "investigation_notes.risk_flag": "High" }).pretty();

// 4. UPDATE: Append a new investigation note to CLM-00001
db.claim_investigations.updateOne(
  { claim_number: "CLM-00001" },
  {
    $push: {
      investigation_notes: {
        investigator: "INV-101",
        note: "Final payout cleared for cheque issuance.",
        risk_flag: "Low",
        date: new Date("2025-03-20")
      }
    }
  }
);

// 5. DELETE: Remove a duplicate/invalid test record
db.claim_investigations.deleteOne({ claim_number: "CLM-99999" });

// 6. AGGREGATION PIPELINE: Claims by Type, Region, and Outcome
print("--- Claims Aggregated by Type, Region, and Outcome ---");
db.claim_investigations.aggregate([
  {
    $group: {
      _id: {
        claim_type: "$claim_type",
        region: "$region",
        outcome: "$outcome"
      },
      total_claims: { $sum: 1 },
      total_claimed_amount: { $sum: "$claim_amount" },
      avg_claimed_amount: { $avg: "$claim_amount" }
    }
  },
  {
    $project: {
      _id: 0,
      claim_type: "$_id.claim_type",
      region: "$_id.region",
      outcome: "$_id.outcome",
      total_claims: 1,
      total_claimed_amount: { $round: ["$total_claimed_amount", 2] },
      avg_claimed_amount: { $round: ["$avg_claimed_amount", 2] }
    }
  },
  { $sort: { total_claimed_amount: -1 } }
]).pretty();
