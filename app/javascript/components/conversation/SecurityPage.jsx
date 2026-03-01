import React from 'react'

const SecurityPage = () => {
  return (
    <div className="h-full overflow-y-auto bg-zinc-950">
      <div className="max-w-3xl mx-auto py-12 px-6 text-[15px] leading-relaxed text-zinc-300">

        {/* Architecture */}
        <section className="mb-10">
          <h2 className="text-lg font-medium mb-3 text-zinc-100">
            Architecture
          </h2>

          <p className="mb-4">
            All infra is provisioned/managed by <span className="font-medium text-zinc-100">Heroku</span> (in <span className="font-medium text-zinc-100">US-based</span> AWS regions), and uses their HA failover. Data is encrypted at rest using AES-256, and TLS 1.2+ in transit. The tool is ephemeral, and wipes data older than 3 months.
          </p>

          <div className="mt-5">
            <h3 className="font-medium mb-1 text-zinc-100">Automated Dependency Scanning</h3>
            <p>
              The codebase is continuously scanned using{' '}
              <a
                href="https://docs.github.com/en/code-security/getting-started/dependabot-quickstart-guide"
                className="text-blue-400 hover:text-blue-300 hover:underline font-medium"
              >
                GitHub Dependabot
              </a>{' '}
              to patch vulnerable libraries. Critical vulnerabilities are patched within 7 days of public disclosure.
            </p>
          </div>

          <div className="mt-5">
            <h3 className="font-medium mb-1 text-zinc-100">Cookie Policy</h3>
            <p>
              This site uses a session ID cookie to track which difficulty you selected. No marketing cookies or analytics JS plugins of any kind.
            </p>
          </div>

          <div className="mt-5">
            <h3 className="font-medium mb-1 text-zinc-100">Database Backups</h3>
            <p>
              <a
                href="https://www.heroku.com/postgres"
                className="text-blue-400 hover:text-blue-300 hover:underline font-medium"
              >
                Heroku Postgres
              </a>{' '}
              maintains rolling database backups, and prunes old snapshots automatically over time. Backups can be restored in minutes, and are captured at least once every 24 hours.
            </p>
          </div>
        </section>

        {/* Data Lifecycle */}
        <section className="mb-10">
          <h2 className="text-lg font-medium mb-3 text-zinc-100">
            Data Lifecycle
          </h2>

          <p>
            Inactive chats are auto-deleted after 3 months.
            Email{' '}
            <a
              href="mailto:support@invariant.training"
              className="text-blue-400 hover:text-blue-300 hover:underline font-medium"
            >
              support@invariant.training
            </a>{' '}
            to request immediate deletion.
          </p>
        </section>

        {/* Subprocessors */}
        <section>
          <h2 className="text-lg font-medium mb-3 text-zinc-100">
            Subprocessors
          </h2>

          <p className="text-sm text-zinc-400 mb-5">
            All vendors are GDPR compliant, offer Standard Contractual Clauses (SCCs), and underwent security review prior to onboarding. This is the complete list. No additional tools (e.g., Google Analytics) are used beyond those listed here.
          </p>

          <div className="space-y-5">
            <div>
              <h3 className="font-medium text-zinc-100">Amazon S3</h3>
              <p>Stores immutable, append-only audits for admin actions (e.g., data removal) with AES-256 at rest.</p>
            </div>

            <div>
              <h3 className="font-medium text-zinc-100">Datadog</h3>
              <p>Used for infrastructure telemetry and monitoring (e.g., CPU, memory, service health).</p>
            </div>

            <div>
              <h3 className="font-medium text-zinc-100">Heroku</h3>
              <p>
                Used for application infra and encrypted storage. All workloads run in isolated containers with TLS 1.2+ enforced, and AES-256 encryption at rest. Includes managed Heroku Postgres + Redis instances.
              </p>
            </div>

            <div>
              <h3 className="font-medium text-zinc-100">OpenAI</h3>
              <p>
                OpenAI's API powers the real-time content generation for the chat. None of your data is persisted by OpenAI. None of it is used to train their models. The prompting is ephemeral.
              </p>
            </div>

            <div>
              <h3 className="font-medium text-zinc-100">PagerDuty</h3>
              <p>
                Used for incident alerting and on-call scheduling. May store system-level alerts with metadata (e.g., timestamps, service names). No user-submitted content.
              </p>
            </div>

            <div>
              <h3 className="font-medium text-zinc-100">Papertrail</h3>
              <p>
                Used for infrastructure log aggregation and retention. Some logs may include metadata related to coaching email delivery (e.g. timestamps, team IDs).
              </p>
            </div>

            <div>
              <h3 className="font-medium text-zinc-100">Sentry</h3>
              <p>
                Used for internal error tracking and debugging. Some error logs may include technical metadata (e.g., error messages, timestamps, team IDs).
              </p>
            </div>
          </div>
        </section>
      </div>
    </div>
  )
}

export default SecurityPage