import React from 'react'

const TermsPage = () => {
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
            <path strokeLinecap="round" strokeLinejoin="round" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
          </svg>
          <span className="text-[15px] font-semibold" style={{ color: '#e4e4e7' }}>Terms of Service</span>
        </div>
      </div>

      {/* Scrollable content area */}
      <div className="flex-1 overflow-y-auto">
        <div className="max-w-2xl mx-auto py-10 px-6 text-[15px] leading-relaxed text-zinc-400">

          {/* Intro */}
          <section className="mb-10">
            <p className="mb-4">
              The website located at invariant.training (the "Site") is a copyrighted work belonging to Replicate Software, LLC ("Company", "us", "our", and "we"). Certain features of the Site may be subject to additional guidelines, terms, or rules, which will be posted on the Site in connection with such features. All such additional terms, guidelines, and rules are incorporated by reference into these Terms.
            </p>
            <p className="mb-4">
              If you've signed a separate written agreement with Replicate Software, LLC (such as a Master Services Agreement), that agreement will govern in the event of any conflict.
            </p>
            <p className="mb-4 text-zinc-300">
              THESE TERMS OF SERVICE (THESE "TERMS") SET FORTH THE LEGALLY BINDING TERMS AND CONDITIONS THAT GOVERN YOUR USE OF THE SITE. BY ACCESSING OR USING THE SITE, YOU ARE ACCEPTING THESE TERMS (ON BEHALF OF YOURSELF OR THE ENTITY THAT YOU REPRESENT), AND YOU REPRESENT AND WARRANT THAT YOU HAVE THE RIGHT, AUTHORITY, AND CAPACITY TO ENTER INTO THESE TERMS (ON BEHALF OF YOURSELF OR THE ENTITY THAT YOU REPRESENT). YOU MAY NOT ACCESS OR USE THE SITE OR ACCEPT THE TERMS IF YOU ARE NOT AT LEAST 18 YEARS OLD. IF YOU DO NOT AGREE WITH ALL OF THE PROVISIONS OF THESE TERMS, DO NOT ACCESS AND/OR USE THE SITE.
            </p>
          </section>

          {/* Arbitration Notice */}
          <section className="mb-10">
            <div className="rounded-lg p-4" style={{ backgroundColor: '#1f1f23', border: '1px solid #27272a' }}>
              <h3 className="font-medium mb-2 text-zinc-200 text-[14px]">⚠️ Arbitration Notice</h3>
              <p className="text-[14px]">
                PLEASE BE AWARE THAT SECTION 10.2 CONTAINS PROVISIONS GOVERNING HOW TO RESOLVE DISPUTES BETWEEN YOU AND COMPANY. AMONG OTHER THINGS, SECTION 10.2 INCLUDES AN AGREEMENT TO ARBITRATE WHICH REQUIRES, WITH LIMITED EXCEPTIONS, THAT ALL DISPUTES BETWEEN YOU AND US SHALL BE RESOLVED BY BINDING AND FINAL ARBITRATION. SECTION 10.2 ALSO CONTAINS A CLASS ACTION AND JURY TRIAL WAIVER.
              </p>
            </div>
          </section>

          {/* 1. Accounts */}
          <section className="mb-10">
            <h2 className="text-[13px] font-semibold uppercase tracking-wider mb-4" style={{ color: '#71717a' }}>
              1. Accounts
            </h2>

            <div className="space-y-3">
              <div className="rounded-lg p-4" style={{ backgroundColor: '#1f1f23', border: '1px solid #27272a' }}>
                <h3 className="font-medium mb-2 text-zinc-200 text-[14px]">1.1 Account Creation</h3>
                <p className="text-[14px]">
                  In order to use certain features of the Site, you must register for an account ("Account") and provide certain information about yourself as prompted by the account registration form. You represent and warrant that: (a) all required registration information you submit is truthful and accurate; (b) you will maintain the accuracy of such information. You may delete your Account at any time, for any reason, by following the instructions on the Site. Company may suspend or terminate your Account in accordance with Section 8.
                </p>
              </div>

              <div className="rounded-lg p-4" style={{ backgroundColor: '#1f1f23', border: '1px solid #27272a' }}>
                <h3 className="font-medium mb-2 text-zinc-200 text-[14px]">1.2 Account Responsibilities</h3>
                <p className="text-[14px]">
                  You are responsible for maintaining the confidentiality of your Account login information and are fully responsible for all activities that occur under your Account. You agree to immediately notify the Company of any unauthorized use, or suspected unauthorized use of your Account or any other breach of security. Company cannot and will not be liable for any loss or damage arising from your failure to comply with the above requirements.
                </p>
              </div>
            </div>
          </section>

          {/* 2. Access to the Site */}
          <section className="mb-10">
            <h2 className="text-[13px] font-semibold uppercase tracking-wider mb-4" style={{ color: '#71717a' }}>
              2. Access to the Site
            </h2>

            <div className="space-y-3">
              <div className="rounded-lg p-4" style={{ backgroundColor: '#1f1f23', border: '1px solid #27272a' }}>
                <h3 className="font-medium mb-2 text-zinc-200 text-[14px]">2.1 License</h3>
                <p className="text-[14px]">
                  Subject to these Terms, Company grants you a non-transferable, non-exclusive, revocable, limited license to use and access the Site solely for your own personal, noncommercial use.
                </p>
              </div>

              <div className="rounded-lg p-4" style={{ backgroundColor: '#1f1f23', border: '1px solid #27272a' }}>
                <h3 className="font-medium mb-2 text-zinc-200 text-[14px]">2.2 Certain Restrictions</h3>
                <p className="text-[14px]">
                  The rights granted to you in these Terms are subject to the following restrictions: (a) you shall not license, sell, rent, lease, transfer, assign, distribute, host, or otherwise commercially exploit the Site; (b) you shall not modify, make derivative works of, disassemble, reverse compile or reverse engineer any part of the Site; (c) you shall not access the Site in order to build a similar or competitive website, product, or service; and (d) except as expressly stated herein, no part of the Site may be copied, reproduced, distributed, republished, downloaded, displayed, posted or transmitted in any form or by any means.
                </p>
              </div>

              <div className="rounded-lg p-4" style={{ backgroundColor: '#1f1f23', border: '1px solid #27272a' }}>
                <h3 className="font-medium mb-2 text-zinc-200 text-[14px]">2.3 Modification</h3>
                <p className="text-[14px]">
                  Company reserves the right, at any time, to modify, suspend, or discontinue the Site (in whole or in part) with or without notice to you. You agree that Company will not be liable to you or to any third party for any modification, suspension, or discontinuation of the Site or any part thereof.
                </p>
              </div>

              <div className="rounded-lg p-4" style={{ backgroundColor: '#1f1f23', border: '1px solid #27272a' }}>
                <h3 className="font-medium mb-2 text-zinc-200 text-[14px]">2.4 No Support or Maintenance</h3>
                <p className="text-[14px]">
                  While we do not provide guaranteed support levels, we aim to respond to all issues in a commercially reasonable timeframe.
                </p>
              </div>

              <div className="rounded-lg p-4" style={{ backgroundColor: '#1f1f23', border: '1px solid #27272a' }}>
                <h3 className="font-medium mb-2 text-zinc-200 text-[14px]">2.5 Ownership</h3>
                <p className="text-[14px]">
                  Excluding any User Content that you may provide (defined below), you acknowledge that all the intellectual property rights, including copyrights, patents, trade marks, and trade secrets, in the Site and its content are owned by Company or Company's suppliers. Neither these Terms (nor your access to the Site) transfers to you or any third party any rights, title or interest in or to such intellectual property rights, except for the limited access rights expressly set forth in Section 2.1. Company and its suppliers reserve all rights not granted in these Terms. There are no implied licenses granted under these Terms.
                </p>
              </div>

              <div className="rounded-lg p-4" style={{ backgroundColor: '#1f1f23', border: '1px solid #27272a' }}>
                <h3 className="font-medium mb-2 text-zinc-200 text-[14px]">2.6 Feedback</h3>
                <p className="text-[14px]">
                  If you provide Company with any feedback or suggestions regarding the Site ("Feedback"), you hereby assign to Company all rights in such Feedback and agree that Company shall have the right to use and fully exploit such Feedback and related information in any manner it deems appropriate. Company will treat any Feedback you provide to Company as non-confidential and non-proprietary.
                </p>
              </div>
            </div>
          </section>

          {/* 3. User Content */}
          <section className="mb-10">
            <h2 className="text-[13px] font-semibold uppercase tracking-wider mb-4" style={{ color: '#71717a' }}>
              3. User Content
            </h2>

            <div className="space-y-3">
              <div className="rounded-lg p-4" style={{ backgroundColor: '#1f1f23', border: '1px solid #27272a' }}>
                <h3 className="font-medium mb-2 text-zinc-200 text-[14px]">3.1 User Content</h3>
                <p className="text-[14px]">
                  "User Content" means any and all information and content that a user submits to, or uses with, the Site. You are solely responsible for your User Content. You assume all risks associated with use of your User Content, including any reliance on its accuracy, completeness or usefulness by others, or any disclosure of your User Content that personally identifies you or any third party.
                </p>
              </div>

              <div className="rounded-lg p-4" style={{ backgroundColor: '#1f1f23', border: '1px solid #27272a' }}>
                <h3 className="font-medium mb-2 text-zinc-200 text-[14px]">3.2 License</h3>
                <p className="text-[14px]">
                  You hereby grant (and you represent and warrant that you have the right to grant) to Company an irrevocable, nonexclusive, royalty-free and fully paid, worldwide license to reproduce, distribute, publicly display and perform, prepare derivative works of, incorporate into other works, and otherwise use and exploit your User Content, and to grant sublicenses of the foregoing rights, solely for the purposes of including your User Content in the Site.
                </p>
              </div>

              <div className="rounded-lg p-4" style={{ backgroundColor: '#1f1f23', border: '1px solid #27272a' }}>
                <h3 className="font-medium mb-2 text-zinc-200 text-[14px]">3.3 Acceptable Use Policy</h3>
                <p className="text-[14px]">
                  You agree not to use the Site to collect, upload, transmit, display, or distribute any User Content that: (i) violates any third-party right, including any copyright, trademark, patent, trade secret, moral right, privacy right, right of publicity, or any other intellectual property or proprietary right; (ii) is unlawful, harassing, abusive, tortious, threatening, harmful, invasive of another's privacy, vulgar, defamatory, false, intentionally misleading, trade libelous, pornographic, obscene, patently offensive, or promotes racism, bigotry, hatred, or physical harm of any kind against any group or individual; (iii) is harmful to minors in any way; or (iv) is in violation of any law, regulation, or obligations or restrictions imposed by any third party.
                </p>
              </div>

              <div className="rounded-lg p-4" style={{ backgroundColor: '#1f1f23', border: '1px solid #27272a' }}>
                <h3 className="font-medium mb-2 text-zinc-200 text-[14px]">3.4 Enforcement</h3>
                <p className="text-[14px]">
                  We reserve the right (but have no obligation) to review, refuse and/or remove any User Content in our sole discretion, and to investigate and/or take appropriate action against you in our sole discretion if you violate the Acceptable Use Policy or any other provision of these Terms or otherwise create liability for us or any other person.
                </p>
              </div>
            </div>
          </section>

          {/* 4. Indemnification */}
          <section className="mb-10">
            <h2 className="text-[13px] font-semibold uppercase tracking-wider mb-4" style={{ color: '#71717a' }}>
              4. Indemnification
            </h2>

            <div className="rounded-lg p-4" style={{ backgroundColor: '#1f1f23', border: '1px solid #27272a' }}>
              <p className="text-[14px]">
                You agree to indemnify and hold Company (and its officers, employees, and agents) harmless, including costs and attorneys' fees, from any claim or demand made by any third party due to or arising out of (a) your use of the Site, (b) your violation of these Terms, (c) your violation of applicable laws or regulations or (d) your User Content. Company reserves the right, at your expense, to assume the exclusive defense and control of any matter for which you are required to indemnify us.
              </p>
            </div>
          </section>

          {/* 5. Third-Party Links & Ads; Other Users */}
          <section className="mb-10">
            <h2 className="text-[13px] font-semibold uppercase tracking-wider mb-4" style={{ color: '#71717a' }}>
              5. Third-Party Links & Ads; Other Users
            </h2>

            <div className="space-y-3">
              <div className="rounded-lg p-4" style={{ backgroundColor: '#1f1f23', border: '1px solid #27272a' }}>
                <h3 className="font-medium mb-2 text-zinc-200 text-[14px]">5.1 Third-Party Links & Ads</h3>
                <p className="text-[14px]">
                  The Site may contain links to third-party websites and services, and/or display advertisements for third parties (collectively, "Third-Party Links & Ads"). Such Third-Party Links & Ads are not under the control of Company, and Company is not responsible for any Third-Party Links & Ads. Company provides access to these Third-Party Links & Ads only as a convenience to you.
                </p>
              </div>

              <div className="rounded-lg p-4" style={{ backgroundColor: '#1f1f23', border: '1px solid #27272a' }}>
                <h3 className="font-medium mb-2 text-zinc-200 text-[14px]">5.2 Other Users</h3>
                <p className="text-[14px]">
                  Each Site user is solely responsible for any and all of its own User Content. Since we do not control User Content, you acknowledge and agree that we are not responsible for any User Content, whether provided by you or by others.
                </p>
              </div>

              <div className="rounded-lg p-4" style={{ backgroundColor: '#1f1f23', border: '1px solid #27272a' }}>
                <h3 className="font-medium mb-2 text-zinc-200 text-[14px]">5.3 Release</h3>
                <p className="text-[14px]">
                  You hereby release and forever discharge Company (and our officers, employees, agents, successors, and assigns) from, and hereby waive and relinquish, each and every past, present and future dispute, claim, controversy, demand, right, obligation, liability, action and cause of action of every kind and nature that has arisen or arises directly or indirectly out of, or that relates directly or indirectly to, the Site.
                </p>
              </div>
            </div>
          </section>

          {/* 6. Disclaimers */}
          <section className="mb-10">
            <h2 className="text-[13px] font-semibold uppercase tracking-wider mb-4" style={{ color: '#71717a' }}>
              6. Disclaimers
            </h2>

            <div className="rounded-lg p-4" style={{ backgroundColor: '#1f1f23', border: '1px solid #27272a' }}>
              <p className="text-[14px] text-zinc-300">
                THE SITE IS PROVIDED ON AN "AS-IS" AND "AS AVAILABLE" BASIS, AND COMPANY (AND OUR SUPPLIERS) EXPRESSLY DISCLAIM ANY AND ALL WARRANTIES AND CONDITIONS OF ANY KIND, WHETHER EXPRESS, IMPLIED, OR STATUTORY, INCLUDING ALL WARRANTIES OR CONDITIONS OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, TITLE, QUIET ENJOYMENT, ACCURACY, OR NON-INFRINGEMENT. WE (AND OUR SUPPLIERS) MAKE NO WARRANTY THAT THE SITE WILL MEET YOUR REQUIREMENTS, WILL BE AVAILABLE ON AN UNINTERRUPTED, TIMELY, SECURE, OR ERROR-FREE BASIS, OR WILL BE ACCURATE, RELIABLE, FREE OF VIRUSES OR OTHER HARMFUL CODE, COMPLETE, LEGAL, OR SAFE.
              </p>
            </div>
          </section>

          {/* 7. Limitation on Liability */}
          <section className="mb-10">
            <h2 className="text-[13px] font-semibold uppercase tracking-wider mb-4" style={{ color: '#71717a' }}>
              7. Limitation on Liability
            </h2>

            <div className="space-y-3">
              <div className="rounded-lg p-4" style={{ backgroundColor: '#1f1f23', border: '1px solid #27272a' }}>
                <p className="text-[14px]">
                  To the maximum extent permitted by law, in no event shall Replicate Software, LLC (or our suppliers) be liable to you or any third party for any lost profits, lost data, costs of procurement of substitute products or services, or any indirect, consequential, exemplary, incidental, special, or punitive damages arising from or relating to these terms or your use of the service, even if advised of the possibility of such damages.
                </p>
              </div>

              <div className="rounded-lg p-4" style={{ backgroundColor: '#1f1f23', border: '1px solid #27272a' }}>
                <p className="text-[14px]">
                  Except for liability resulting from gross negligence, confidentiality breaches, IP infringement, or indemnification obligations, our total aggregate liability for all claims under this agreement is capped at <span className="text-zinc-200">five (5) times</span> the fees paid for your entire contract. The existence of more than one claim does not increase this limit.
                </p>
              </div>
            </div>
          </section>

          {/* 8. Term and Termination */}
          <section className="mb-10">
            <h2 className="text-[13px] font-semibold uppercase tracking-wider mb-4" style={{ color: '#71717a' }}>
              8. Term and Termination
            </h2>

            <div className="rounded-lg p-4" style={{ backgroundColor: '#1f1f23', border: '1px solid #27272a' }}>
              <p className="text-[14px]">
                Subject to this Section, these Terms will remain in full force and effect while you use the Site. We may suspend or terminate your rights to use the Site (including your Account) at any time for any reason at our sole discretion, including for any use of the Site in violation of these Terms. Upon termination of your rights under these Terms, your Account and right to access and use the Site will terminate immediately. You understand that any termination of your Account may involve deletion of your User Content associated with your Account from our live databases.
              </p>
            </div>
          </section>

          {/* 9. Copyright Policy */}
          <section className="mb-10">
            <h2 className="text-[13px] font-semibold uppercase tracking-wider mb-4" style={{ color: '#71717a' }}>
              9. Copyright Policy
            </h2>

            <div className="rounded-lg p-4" style={{ backgroundColor: '#1f1f23', border: '1px solid #27272a' }}>
              <p className="text-[14px] mb-4">
                Company respects the intellectual property of others and asks that users of our Site do the same. If you believe that one of our users is, through the use of our Site, unlawfully infringing the copyright(s) in a work, and wish to have the allegedly infringing material removed, the following information in the form of a written notification (pursuant to 17 U.S.C. § 512(c)) must be provided to our designated Copyright Agent:
              </p>
              <ul className="list-disc list-inside text-[14px] space-y-1 text-zinc-400">
                <li>your physical or electronic signature</li>
                <li>identification of the copyrighted work(s) that you claim to have been infringed</li>
                <li>identification of the material on our services that you claim is infringing</li>
                <li>sufficient information to permit us to locate such material</li>
                <li>your address, telephone number, and e-mail address</li>
                <li>a statement that you have a good faith belief that use of the objectionable material is not authorized</li>
                <li>a statement that the information in the notification is accurate, and under penalty of perjury, that you are either the owner of the copyright or authorized to act on behalf of the copyright owner</li>
              </ul>
            </div>
          </section>

          {/* 10. General */}
          <section className="mb-10">
            <h2 className="text-[13px] font-semibold uppercase tracking-wider mb-4" style={{ color: '#71717a' }}>
              10. General
            </h2>

            <div className="space-y-3">
              <div className="rounded-lg p-4" style={{ backgroundColor: '#1f1f23', border: '1px solid #27272a' }}>
                <h3 className="font-medium mb-2 text-zinc-200 text-[14px]">10.1 Changes</h3>
                <p className="text-[14px]">
                  These Terms are subject to occasional revision, and if we make any substantial changes, we may notify you by sending you an e-mail to the last e-mail address you provided to us (if any), and/or by prominently posting notice of the changes on our Site.
                </p>
              </div>

              <div className="rounded-lg p-4" style={{ backgroundColor: '#1f1f23', border: '1px solid #27272a' }}>
                <h3 className="font-medium mb-2 text-zinc-200 text-[14px]">10.2 Dispute Resolution</h3>
                <p className="text-[14px]">
                  You agree that any dispute between you and Company relating in any way to the Site will be resolved by binding arbitration, rather than in court, except that (1) you and the Company Parties may assert individualized claims in small claims court if the claims qualify; and (2) you or the Company Parties may seek equitable relief in court for infringement or other misuse of intellectual property rights.
                </p>
              </div>

              <div className="rounded-lg p-4" style={{ backgroundColor: '#1f1f23', border: '1px solid #27272a' }}>
                <h3 className="font-medium mb-2 text-zinc-200 text-[14px]">10.3 Export</h3>
                <p className="text-[14px]">
                  The Site may be subject to U.S. export control laws and may be subject to export or import regulations in other countries. You agree not to export, reexport, or transfer, directly or indirectly, any U.S. technical data acquired from Company, or any products utilizing such data, in violation of the United States export laws or regulations.
                </p>
              </div>

              <div className="rounded-lg p-4" style={{ backgroundColor: '#1f1f23', border: '1px solid #27272a' }}>
                <h3 className="font-medium mb-2 text-zinc-200 text-[14px]">10.4 Electronic Communications</h3>
                <p className="text-[14px]">
                  The communications between you and Company use electronic means. For contractual purposes, you (a) consent to receive communications from Company in an electronic form; and (b) agree that all terms and conditions, agreements, notices, disclosures, and other communications that Company provides to you electronically satisfy any legal requirement that such communications would satisfy if it were in hardcopy writing.
                </p>
              </div>

              <div className="rounded-lg p-4" style={{ backgroundColor: '#1f1f23', border: '1px solid #27272a' }}>
                <h3 className="font-medium mb-2 text-zinc-200 text-[14px]">10.5 Entire Terms</h3>
                <p className="text-[14px]">
                  These Terms constitute the entire agreement between you and us regarding the use of the Site. Our failure to exercise or enforce any right or provision of these Terms shall not operate as a waiver of such right or provision.
                </p>
              </div>

              <div className="rounded-lg p-4" style={{ backgroundColor: '#1f1f23', border: '1px solid #27272a' }}>
                <h3 className="font-medium mb-2 text-zinc-200 text-[14px]">10.6 Copyright/Trademark Information</h3>
                <p className="text-[14px]">
                  Copyright © 2025 Replicate Software, LLC. All rights reserved. All trademarks, logos and service marks ("Marks") displayed on the Site are our property or the property of other third parties. You are not permitted to use these Marks without our prior written consent or the consent of such third party which may own the Marks.
                </p>
              </div>
            </div>
          </section>

          {/* Contact */}
          <section className="mb-10">
            <h2 className="text-[13px] font-semibold uppercase tracking-wider mb-4" style={{ color: '#71717a' }}>
              Contact Information
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

export default TermsPage