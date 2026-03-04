import React from 'react'

const PrivacyPage = () => {
  return (
    <div className="flex flex-col h-full overflow-hidden" style={{ backgroundColor: '#18181a' }}>
      {/* Page header - matches conversation view */}
      <div
        className="flex-shrink-0 flex items-center px-5 py-3"
        style={{
          borderBottom: '1px solid #27272a',
        }}
      >
        <div className="flex items-center gap-2">
          <svg className="w-4 h-4" style={{ color: '#71717a' }} fill="none" stroke="currentColor" strokeWidth="2" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" />
          </svg>
          <span className="text-[15px] font-semibold" style={{ color: '#e4e4e7' }}>Privacy</span>
        </div>
      </div>

      {/* Scrollable content area */}
      <div className="flex-1 overflow-y-auto">
        <div className="max-w-2xl mx-auto py-10 px-6 text-[15px] leading-relaxed text-zinc-400">

          {/* Information Collected */}
          <section className="mb-10">
            <h2 className="text-[13px] font-semibold uppercase tracking-wider mb-4" style={{ color: '#71717a' }}>
              Information Collected
            </h2>

            <div className="rounded-lg p-4" style={{ backgroundColor: '#1f1f23', border: '1px solid #27272a' }}>
              <h3 className="font-medium mb-2 text-zinc-200 text-[14px]">Conversation History</h3>
              <p className="text-[14px]">
                Copies of your coaching threads, stored temporarily to deliver replies in case you reopen an old conversation. They're automatically deleted after 3 months of inactivity.
              </p>
            </div>
          </section>

          {/* Subprocessors */}
          <section className="mb-10">
            <h2 className="text-[13px] font-semibold uppercase tracking-wider mb-4" style={{ color: '#71717a' }}>
              Subprocessors
            </h2>

            <div className="rounded-lg p-4 mb-5" style={{ backgroundColor: '#1f1f23', border: '1px solid #27272a' }}>
              <p className="text-[14px]">
                We do <span className="text-zinc-200 font-medium">not</span> sell, rent, or share your information for marketing purposes.
              </p>
            </div>

            <p className="text-[13px] text-zinc-500 mb-5">
              All vendors are GDPR compliant, offer Standard Contractual Clauses (SCCs), and underwent security review prior to onboarding. This is the complete list. No additional tools (e.g., Google Analytics) are used beyond those listed here.
            </p>

            <div className="grid gap-3">
              <div className="rounded-lg p-4" style={{ backgroundColor: '#1f1f23', border: '1px solid #27272a' }}>
                <h3 className="font-medium text-zinc-200 text-[14px] mb-1">Amazon S3</h3>
                <p className="text-[14px]">Stores immutable, append-only audits for admin actions (e.g., data removal) with AES-256 at rest.</p>
              </div>

              <div className="rounded-lg p-4" style={{ backgroundColor: '#1f1f23', border: '1px solid #27272a' }}>
                <h3 className="font-medium text-zinc-200 text-[14px] mb-1">Datadog</h3>
                <p className="text-[14px]">Used for infrastructure telemetry and monitoring (e.g., CPU, memory, service health).</p>
              </div>

              <div className="rounded-lg p-4" style={{ backgroundColor: '#1f1f23', border: '1px solid #27272a' }}>
                <h3 className="font-medium text-zinc-200 text-[14px] mb-1">Heroku</h3>
                <p className="text-[14px]">
                  Used for application infra and encrypted storage. All workloads run in isolated containers with TLS 1.2+ enforced, and AES-256 encryption at rest. Includes managed Heroku Postgres + Redis instances.
                </p>
              </div>

              <div className="rounded-lg p-4" style={{ backgroundColor: '#1f1f23', border: '1px solid #27272a' }}>
                <h3 className="font-medium text-zinc-200 text-[14px] mb-1">OpenAI</h3>
                <p className="text-[14px]">
                  OpenAI's API powers the real-time content generation for the chat. None of your data is persisted by OpenAI. None of it is used to train their models. The prompting is ephemeral.
                </p>
              </div>

              <div className="rounded-lg p-4" style={{ backgroundColor: '#1f1f23', border: '1px solid #27272a' }}>
                <h3 className="font-medium text-zinc-200 text-[14px] mb-1">PagerDuty</h3>
                <p className="text-[14px]">
                  Used for incident alerting and on-call scheduling. May store system-level alerts with metadata (e.g., timestamps, service names). No user-submitted content.
                </p>
              </div>

              <div className="rounded-lg p-4" style={{ backgroundColor: '#1f1f23', border: '1px solid #27272a' }}>
                <h3 className="font-medium text-zinc-200 text-[14px] mb-1">Papertrail</h3>
                <p className="text-[14px]">
                  Used for infrastructure log aggregation and retention. Some logs may include metadata related to coaching email delivery (e.g. timestamps, team IDs).
                </p>
              </div>

              <div className="rounded-lg p-4" style={{ backgroundColor: '#1f1f23', border: '1px solid #27272a' }}>
                <h3 className="font-medium text-zinc-200 text-[14px] mb-1">Sentry</h3>
                <p className="text-[14px]">
                  Used for internal error tracking and debugging. Some error logs may include technical metadata (e.g., error messages, timestamps, team IDs).
                </p>
              </div>
            </div>
          </section>

          {/* Children's Privacy */}
          <section>
            <h2 className="text-[13px] font-semibold uppercase tracking-wider mb-4" style={{ color: '#71717a' }}>
              Children's Privacy
            </h2>

            <div className="rounded-lg p-4" style={{ backgroundColor: '#1f1f23', border: '1px solid #27272a' }}>
              <p className="text-[14px]">
                This service is not directed to individuals under 13, and we do not knowingly collect data from them.
              </p>
            </div>
          </section>

        </div>
      </div>
    </div>
  )
}

export default PrivacyPage