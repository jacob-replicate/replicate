import React from 'react'

const AboutPage = () => {
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
            <path strokeLinecap="round" strokeLinejoin="round" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
          </svg>
          <span className="text-[15px] font-semibold" style={{ color: '#e4e4e7' }}>About</span>
        </div>
      </div>

      {/* Scrollable content area */}
      <div className="flex-1 overflow-y-auto">
        <div className="max-w-2xl mx-auto py-10 px-6 text-[15px] leading-relaxed text-zinc-400">

          {/* What it is */}
          <section className="mb-10">
            <h2 className="text-[13px] font-semibold uppercase tracking-wider mb-4" style={{ color: '#71717a' }}>
              What Invariant Is
            </h2>

            <p className="mb-4">
              Invariant is a <span className="text-zinc-200">single-player incident simulation</span> that trains production judgment through consequence-based interaction.
            </p>
            <p className="mb-4">
              Not a course. Not a quiz. Not a checklist. It's a <span className="text-zinc-200">cognitive gym</span>: realistic incident → ambiguity → decisions → consequences → mental model sharpening.
            </p>
          </section>

          {/* How it works */}
          <section className="mb-10">
            <h2 className="text-[13px] font-semibold uppercase tracking-wider mb-4" style={{ color: '#71717a' }}>
              How It Works
            </h2>

            <div className="space-y-3">
              <div className="rounded-lg p-4" style={{ backgroundColor: '#1f1f23', border: '1px solid #27272a' }}>
                <h3 className="font-medium mb-2 text-zinc-200 text-[14px]">Immersion, Not Instruction</h3>
                <p className="text-[14px]">
                  There's no trainer narration. You're inside an incident channel with believable teammates, logs, and graphs. The interface disappears — the incident dominates.
                </p>
              </div>

              <div className="rounded-lg p-4" style={{ backgroundColor: '#1f1f23', border: '1px solid #27272a' }}>
                <h3 className="font-medium mb-2 text-zinc-200 text-[14px]">Consequences, Not Grades</h3>
                <p className="text-[14px]">
                  We never say "wrong." The system responds with realistic outcomes — tradeoffs, side-effects, follow-on failures. Good thinking makes the system behave better, not praise you.
                </p>
              </div>

              <div className="rounded-lg p-4" style={{ backgroundColor: '#1f1f23', border: '1px solid #27272a' }}>
                <h3 className="font-medium mb-2 text-zinc-200 text-[14px]">Scaffolding Fades</h3>
                <p className="text-[14px]">
                  Early on you pick from multiple-choice options. They gradually disappear until you're typing freely — diagnosing, deciding, and responding on your own.
                </p>
              </div>
            </div>
          </section>

          {/* What we train */}
          <section className="mb-10">
            <h2 className="text-[13px] font-semibold uppercase tracking-wider mb-4" style={{ color: '#71717a' }}>
              What We Train
            </h2>

            <p className="mb-5 text-[14px]">
              An <span className="text-zinc-200">invariant</span> is what must remain true, even under stress, partial failure, and retries. Each scenario sharpens judgment around a specific class of production failure.
            </p>

            <div className="grid grid-cols-2 gap-2">
              {[
                'Idempotency',
                'Retry Safety',
                'Backpressure',
                'Connection Pooling',
                'Race Conditions',
                'Causal Ordering',
                'Load Shedding',
                'Queue Collapse',
                'Timeouts',
                'Bounded Work',
                'Locking & Isolation',
                'Trust Boundaries',
              ].map((topic) => (
                <div
                  key={topic}
                  className="rounded px-3 py-2 text-[13px] font-mono"
                  style={{ backgroundColor: '#1f1f23', border: '1px solid #27272a', color: '#a1a1aa' }}
                >
                  {topic}
                </div>
              ))}
            </div>
          </section>

          {/* Quality bar */}
          <section className="mb-10">
            <h2 className="text-[13px] font-semibold uppercase tracking-wider mb-4" style={{ color: '#71717a' }}>
              Quality Bar
            </h2>

            <div className="rounded-lg p-4" style={{ backgroundColor: '#1f1f23', border: '1px solid #27272a' }}>
              <p className="text-[14px] mb-3">A good run produces:</p>
              <ul className="space-y-2 text-[14px]">
                <li className="flex items-start gap-2">
                  <span className="text-zinc-600 mt-0.5">—</span>
                  <span>A transcript that reads like a real incident</span>
                </li>
                <li className="flex items-start gap-2">
                  <span className="text-zinc-600 mt-0.5">—</span>
                  <span>At least one "wince" moment for experienced engineers</span>
                </li>
                <li className="flex items-start gap-2">
                  <span className="text-zinc-600 mt-0.5">—</span>
                  <span>Clear cognitive strain — tradeoffs, uncertainty, consequences</span>
                </li>
                <li className="flex items-start gap-2">
                  <span className="text-zinc-600 mt-0.5">—</span>
                  <span>A changed mental model: <span className="text-zinc-300 italic">"oh, that invariant is what I violated"</span></span>
                </li>
              </ul>
            </div>
          </section>

          {/* Contact */}
          <section>
            <h2 className="text-[13px] font-semibold uppercase tracking-wider mb-4" style={{ color: '#71717a' }}>
              Contact
            </h2>

            <div className="rounded-lg p-4" style={{ backgroundColor: '#1f1f23', border: '1px solid #27272a' }}>
              <p className="text-[14px]">
                <a href="mailto:support@invariant.training" className="text-blue-400 hover:text-blue-300 hover:underline">
                  support@invariant.training
                </a>
              </p>
            </div>
          </section>

        </div>
      </div>
    </div>
  )
}

export default AboutPage