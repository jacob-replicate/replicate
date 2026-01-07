# db/seeds.rb
# frozen_string_literal: true

puts "\n== Seeding Raft experience =="
Experience.where(template: false).destroy_all

raft = Experience.find_or_create_by!(code: "raft") do |e|
  e.template = true
  e.name = "Let's see how well you understand <span class='font-semibold'>Raft</span>"
  e.description = "Raft is a <span class='font-semibold'>distributed consensus algorithm</span> designed to keep a cluster of machines in agreement despite failures. It provides a single authoritative history by coordinating leader election, log replication, and commitment, prioritizing correctness and safety over availability. Let’s map out what you know, and then fill in the gaps."
end

# Recreate from scratch each seed run (keeps it deterministic and mock-faithful)
Element.where(experience_id: raft.id).delete_all

def list!(experience:, name:, sort:)
  Element.create!(
    experience_id: experience.id,
    element_id: nil,
    code: "ConversationList",
    context: {
      "name" => name,
      "sort" => sort
    }
  )
end

def row!(experience:, parent:, name:, sort:, cta: "Start", state: "idle")
  Element.create!(
    experience_id: experience.id,
    element_id: parent.id,
    code: "ConversationListRow",
    context: {
      "name" => name,
      "sort" => sort,
      # Optional UI hints: safe if your renderer ignores them
      "cta" => cta,          # "Start" | "Continue"
      "state" => state       # "idle" | "in_progress" | "complete"
    }
  )
end

sort = 0

# --- Elections and Leadership (matches your mock section) ---
sort += 10
elections = list!(experience: raft, name: "Elections and Leadership", sort: sort)

row!(experience: raft, parent: elections, sort: 10, name: "How can an election keep failing without electing a leader, even if most nodes are healthy?" )
row!(experience: raft, parent: elections, sort: 20, name: "What actually prevents two leaders from existing at the same time?" )
row!(experience: raft, parent: elections, sort: 30, name: "Why does Raft require votes to be durably persisted before responding?" )
row!(experience: raft, parent: elections, sort: 40, name: "Why does Raft use randomized election timeouts?" )
row!(experience: raft, parent: elections, sort: 70, name: "Why is 'one vote per term' not sufficient by itself to prevent split-brain? What else must be true?" )
row!(experience: raft, parent: elections, sort: 90, name: "What failure mode appears if election timeout is too close to your heartbeat interval under jitter?" )

sort += 10
freshness = list!(experience: raft, name: "Log Freshness", sort: sort)

row!(experience: raft, parent: freshness, sort: 10, name: "Why does a follower compare (lastTerm, lastIndex) before granting a vote?" )
row!(experience: raft, parent: freshness, sort: 20, name: "Can a newly elected leader delete entries from another node’s log? If so, when and why is it safe?" )

# Hard log invariants
row!(experience: raft, parent: freshness, sort: 30, name: "Give a concrete scenario where a candidate with the highest lastIndex must still lose the election." )
row!(experience: raft, parent: freshness, sort: 50, name: "Why does Raft compare lastTerm first (then lastIndex) instead of only lastIndex?" )
row!(experience: raft, parent: freshness, sort: 60, name: "If a follower’s log is divergent, what is the minimal information the leader needs to safely force convergence?" )

# --- Log Replication and Commit (the 2:00am outage category) ---
sort += 10
replication = list!(experience: raft, name: "Log Replication and Commit", sort: sort)

row!(experience: raft, parent: replication, sort: 10, name: "What does it mean for an entry to be 'committed' in Raft? What does it explicitly <span class='font-semibold'>not</span> guarantee?" )
row!(experience: raft, parent: replication, sort: 20, name: "Why can a leader not safely 'commit by counting replicas' for entries from older terms?" )
row!(experience: raft, parent: replication, sort: 50, name: "Why is the commit index monotonic, and what breaks if it isn’t?" )
row!(experience: raft, parent: replication, sort: 70, name: "What’s the invariant relationship between matchIndex[], nextIndex[], and commitIndex on the leader?" )

# --- Persistence and Crash Recovery ---
sort += 10
persistence = list!(experience: raft, name: "Crash Recovery", sort: sort)

row!(experience: raft, parent: persistence, sort: 10, name: "What must be persisted before responding to RPCs? What bug appears if you persist them after?" )
row!(experience: raft, parent: persistence, sort: 20, name: "A node crashes after appending to its log but before fsync. What what must never happen here?" )
row!(experience: raft, parent: persistence, sort: 30, name: "A follower applies an entry to the state machine, then crashes before persisting the corresponding log entry..." )

# --- Snapshots and Compaction ---
sort += 10
snapshots = list!(experience: raft, name: "Snapshots / Compaction", sort: sort)

row!(experience: raft, parent: snapshots, sort: 20, name: "When a follower installs a snapshot, what must happen to its log, commitIndex, and lastApplied—exactly?" )
row!(experience: raft, parent: snapshots, sort: 30, name: "How can snapshot installation race with AppendEntries, and what ordering constraints prevent state regression?" )
row!(experience: raft, parent: snapshots, sort: 40, name: "If you compact too aggressively, which invariants around log freshness and voting can you accidentally break?" )

# --- Membership Changes and Reconfiguration ---
sort += 10
reconfig = list!(experience: raft, name: "Cluster Membership", sort: sort)

row!(experience: raft, parent: reconfig, sort: 10, name: "Why is one-step membership change unsafe in Raft? Give the concrete split-brain sequence." )
row!(experience: raft, parent: reconfig, sort: 20, name: "How does joint consensus prevent two different majorities from each electing a leader?" )
row!(experience: raft, parent: reconfig, sort: 30, name: "During joint consensus, what does 'majority' mean for elections and for committing entries?" )

# --- Client Semantics and Linearizability (where systems lie to you) ---
sort += 10
clients = list!(experience: raft, name: "Client Semantics", sort: sort)

row!(experience: raft, parent: clients, sort: 10, name: "How does Raft ensure linearizable reads? Why is 'read from leader memory' not sufficient?" )
row!(experience: raft, parent: clients, sort: 20, name: "Explain 'lease reads' vs 'ReadIndex' (or equivalent). What clock / network assumptions do leases smuggle in?" )
row!(experience: raft, parent: clients, sort: 30, name: "What should happen when a leader receives a client write, but has not yet committed an entry in its current term?" )
row!(experience: raft, parent: clients, sort: 40, name: "How do you make client requests idempotent across leader failover without violating the state machine?" )

# --- Timing and Network Pathologies (the real world) ---
sort += 10
pathologies = list!(experience: raft, name: "Network Timing", sort: sort)

row!(experience: raft, parent: pathologies, sort: 20, name: "What happens if your transport reorders or duplicates RPCs and you rely on 'latest message wins' logic?" )
row!(experience: raft, parent: pathologies, sort: 30, name: "How does Raft behave under long GC pauses or CPU starvation, and what metrics reveal you’re in that failure mode?" )
row!(experience: raft, parent: pathologies, sort: 40, name: "If your network occasionally delays packets by seconds, how do you choose election timeout bounds without causing perpetual leader churn?" )

puts "Seeded Raft experience: #{raft.id} (#{raft.code})"
puts "Elements: #{Element.where(experience_id: raft.id).count}"
puts "== Done ==\n"