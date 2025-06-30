class StaticController < ApplicationController
  def index
    @example_emails = [
      {
        to: "Alex Shaw",
        subject: "N+1 queries explained in 30 seconds",
        content: "One query quietly explodes into hundreds. This pattern hides in loops, and often won’t show up until we hit real traffic...",
        prompt: "we took production down for 8 minutes (due to forgetting to add a DB index)"
      },
      {
        to: "Taylor Morales",
        subject: "Flaky tests cost more than you think",
        content: "If a test fails for the wrong reason, we learn to ignore it — until we ignore the right failures too. Flaky tests kill trust in CI.",
        prompt: "team ignoring flaky CI failures, and let real bug ship to prod"
      },
      {
        to: "Jacob Comer",
        subject: "Is it a bug, or a new feature?",
        content: "Bug reports that ask for behavior no one agreed to are product creep in disguise. Here are some tips to handle that.",
        prompt: "treating bugs as opportunity for scope creep"
      }
    ]
  end

  def terms
    redirect_to "https://docs.google.com/document/d/1C0zn0671Wg4czBThwsL6bT7Db3btpAsfJepTAMclnuU", allow_other_host: true
  end

  def privacy
    redirect_to "https://docs.google.com/document/d/1SZEi3VcuNtLCLhg44WaSDuNTfndmT9BqdF5-djxKEeM", allow_other_host: true
  end

  def pricing
    redirect_to "https://docs.google.com/document/d/15y7929kcBgyIA19VQOQkdSbIXYb2jXmhrwKRGtw59Tk", allow_other_host: true
  end

  def security
    redirect_to "https://docs.google.com/document/d/1rqwWku--SR-HS86kNIdHMhG-GRfn9QCCxcAARYOYLpA", allow_other_host: true
  end

  def features
    redirect_to "https://docs.google.com/document/d/1wvh5NP537XPxR9aYDnADGVbqcUkWOUdFCJpCSvSyPRA", allow_other_host: true
  end

  def request_demo
    redirect_to "https://forms.gle/PWjALvJkMR8ShNa79", allow_other_host: true
  end
end