---
title: "Glossary — Eviction Research Network"
description: "Plain-language definitions of the housing, eviction, and displacement terms used across Eviction Research Network maps, reports, and data products."
keywords: "eviction glossary, displacement terms, housing precarity definitions, HPRM glossary, EDR, EER, area median income, unlawful detainer"
kicker: "Reference"
h1: "A glossary of <em>eviction &amp; displacement</em> terms."
lead: "The words behind the data. These are the terms that recur across our maps, reports, and risk models — written to be read without a subscription or a statistics degree. Use the A–Z jumps or the filter box to find one."
updated: "2026-06-22"
---

<!-- =============================================================================
     glossary.md — Eviction Research Network
     -----------------------------------------------------------------------------
     EDITABLE SOURCE for glossary.html. Edit this file, then regenerate the page:

         Rscript code/render_glossary.R

     FORMAT
       • Front matter (between the --- lines above) sets page meta. `h1` and
         `lead` may contain inline HTML (e.g. <em>).
       • Each entry begins with a level-2 heading:  ## Term name
       • Immediately under the term, optional metadata lines (any order):
             Category: <one category label>
             Also known as: <comma-separated synonyms>
             See also: <comma-separated term names — auto-linked if they exist>
       • Everything after the metadata, until the next "## ", is the definition.
         Blank lines separate paragraphs. Inline markdown supported:
             **bold**   *italic*   `code`   [link text](https://url)
       • Anchors/slugs are derived from the term (parenthetical abbreviations are
         dropped), so "Hard displacement" → #hard-displacement. Link to a term
         from anywhere on the site with  href="glossary.html#hard-displacement".
       • Order here does not matter; the renderer sorts entries alphabetically.
     ============================================================================= -->

## American Community Survey (ACS)
Category: Geography & data
The U.S. Census Bureau's ongoing survey of households. ERN draws most of its demographic, income, and housing inputs from the ACS **5-year estimates**, which pool five years of responses to produce reliable figures for small areas such as census tracts.

## Area Median Income (AMI)
Category: Income & housing
See also: AMI tiers, Cost burden
The midpoint of household income for a county or metropolitan area, published each year by HUD. Affordability and program-eligibility thresholds are usually written as a share of AMI — for example, a unit "affordable at 50% of AMI."

## AMI tiers (ELI, VLI, LI)
Category: Income & housing
See also: Area Median Income, Estimated Displacement Risk
Standard income bands used to target housing need: **Extremely Low Income** (ELI, 0–30% of AMI), **Very Low Income** (VLI, 30–50%), and **Low Income** (LI, 50–80%). The HPRM models displacement risk separately for each tier.

## Bayesian Additive Regression Trees (BART)
Category: Risk model
See also: Housing Precarity Risk Model, Estimated Displacement Risk, Estimated Eviction Risk
A machine-learning method that sums many small regression trees to predict an outcome flexibly while quantifying uncertainty. ERN uses BART to estimate both displacement (EDR) and eviction (EER) risk from census predictors.

## Census tract
Category: Geography & data
See also: GEOID
A small, relatively stable geographic unit defined by the Census Bureau, typically holding 1,200–8,000 people. Tracts are the primary unit of analysis for ERN's national models — roughly 83,500 of them cover the contiguous United States.

## Choropleth
Category: Geography & data
A thematic map that shades areas by the value of a variable (darker usually meaning higher). ERN's interactive risk maps are choropleths of census tracts or counties.

## Composite HPRM score
Category: Risk model
See also: Housing Precarity Risk Model, Estimated Displacement Risk, Estimated Eviction Risk, Divergence
The combined Housing Precarity Risk Model score: the sum of the displacement (EDR) and eviction (EER) sub-scores. It runs from **0** (no measured risk) to **8** (extreme risk on both dimensions).

## Cost burden (rent burden)
Category: Income & housing
See also: Renter household
Spending more than 30% of household income on housing; spending more than 50% is **severe** cost burden. Cost-burdened renters have little cushion against a rent increase, which raises their exposure to displacement and eviction.

## Displacement
Category: Displacement & neighborhood change
See also: Hard displacement, Soft displacement, Gentrification
The involuntary movement of residents out of their home or neighborhood because of forces they cannot control — rising rents, eviction, redevelopment, or the loss of affordable units. ERN distinguishes **hard** and **soft** displacement.

## Divergence
Category: Risk model
See also: Composite HPRM score, Estimated Displacement Risk, Estimated Eviction Risk
An HPRM classification of how a neighborhood's two risks line up: **Convergent** (both displacement and eviction risk present), **EDR-Dominant** (market displacement without much formal eviction), **EER-Dominant** (formal eviction without measured out-migration), or **Neither**.

## Estimated Displacement Risk (EDR)
Category: Risk model
See also: Soft displacement, Housing Precarity Risk Model, Bayesian Additive Regression Trees, AMI tiers
The HPRM sub-model for **soft** displacement: the predicted net out-migration of low-income renter households driven by market pressure such as rising rents and neighborhood change. It is estimated with BART across three AMI tiers and binned into At Risk, Elevated, High, and Extreme.

## Estimated Eviction Risk (EER)
Category: Risk model
See also: Hard displacement, Eviction filing rate ratio, Housing Precarity Risk Model
The HPRM sub-model for **hard** displacement: a neighborhood's formal eviction pressure, measured as its eviction filing rate relative to the state average and modeled nationally with BART. It is binned into At Risk, Elevated, High, and Extreme.

## Eviction
Category: Eviction & court process
See also: Eviction filing, Unlawful detainer
The legal process by which a landlord removes a tenant from a rental unit. In data terms ERN usually measures eviction through **court records**, which capture formal filings and judgments but not informal ("self-help" or off-the-books) removals.

## Eviction filing
Category: Eviction & court process
See also: Eviction, Eviction filing rate, Serial filing
A landlord's formal start of an eviction case in court. A filing is not the same as a removal — many are dismissed, settled, or used as a debt-collection tactic — but filings are the most consistently recorded signal of eviction pressure.

## Eviction filing rate
Category: Eviction & court process
See also: Eviction filing, Renter household
The number of eviction cases filed per 100 (or per 1,000) renter households in an area over a period. Dividing by renter households makes filing activity comparable across places of different size.

## Eviction filing rate ratio
Category: Eviction & court process
See also: Estimated Eviction Risk, Eviction filing rate
A tract's eviction filing rate divided by its state's average rate, so **1.0** means "typical for the state" and **2.0** means "twice the state average." The EER model predicts this ratio to keep eviction risk comparable across states.

## Eviction record (sealing)
Category: Eviction & court process
See also: Serial filing, Tenant protection
The court record an eviction filing creates, which tenant-screening companies use to deny future housing — even when the case was dismissed or the tenant won. **Sealing** laws hide or expunge these records so a single filing doesn't follow a tenant for years.

## Gentrification
Category: Displacement & neighborhood change
See also: Displacement, Soft displacement, Neighborhood typology
The process by which an influx of higher-income residents and investment raises property values and rents in a historically lower-income neighborhood, often pricing out long-term residents. Gentrification is *one driver* of displacement, not a synonym for it.

## GEOID
Category: Geography & data
See also: Census tract
The unique identifier for a Census geography. A tract GEOID is an 11-digit FIPS code — 2 digits of state, 3 of county, 6 of tract. It is the key used to join ERN model output to other datasets.

## Hard displacement
Category: Displacement & neighborhood change
See also: Soft displacement, Estimated Eviction Risk, Eviction
Displacement through a formal, involuntary event — most often eviction, but also condemnation or the expiration of an affordability agreement. ERN proxies hard displacement with eviction filings, via the EER model.

## Housing Choice Voucher (Section 8)
Category: Policy & protections
See also: Cost burden, Renter household
The largest federal rental-assistance program, which pays part of a low-income household's rent directly to a private landlord. Voucher holders can still face displacement when landlords refuse vouchers or when local rents exceed the program's payment standards.

## Housing Precarity Risk Model (HPRM)
Category: Risk model
See also: Estimated Displacement Risk, Estimated Eviction Risk, Composite HPRM score
ERN's national, census-tract index of housing instability. It combines a displacement sub-model (EDR) and an eviction sub-model (EER) into a single 0–8 score that flags where low-income renters face the greatest risk. See [the live model](https://evictionresearch.net/hprm/).

## Just cause eviction
Category: Policy & protections
See also: Notice to vacate, Tenant protection
A protection that lets landlords end a tenancy only for specified, legitimate reasons — such as nonpayment or a lease violation — rather than arbitrarily. Just-cause laws curb no-fault and retaliatory evictions.

## Neighborhood typology
Category: Displacement & neighborhood change
See also: Gentrification, Displacement
A classification of neighborhoods by their stage of housing-market and socioeconomic change — for example, stable, at-risk, actively gentrifying, or advanced gentrification. Typologies help match the right intervention to the right stage.

## Net migration rate (NMR)
Category: Risk model
See also: Estimated Displacement Risk, Soft displacement, AMI tiers
Predicted in-migration minus out-migration of households for a tract — the raw quantity behind the EDR model. A strongly negative NMR for low-income renters signals the out-flow consistent with displacement.

## Notice to vacate (notice period)
Category: Policy & protections
See also: Just cause eviction, Eviction filing
The written notice a landlord must give before filing to evict, and the minimum number of days a tenant has to respond. Length is set by state law — Washington, for example, expanded its pay-or-vacate notice from **3 to 14 days**, a change ERN's disparity analysis helped support.

## Permanent supportive housing (PSH)
Category: Policy & protections
Long-term, affordable housing paired with voluntary services — case management, health care — for people with disabilities or histories of homelessness, with no requirement to "earn" housing through treatment compliance. A core **Housing First** model.

## Redlining
Category: Policy & protections
See also: Gentrification, Displacement
The federally backed 1930s practice of grading neighborhoods for mortgage risk and denying credit to areas with Black and immigrant residents. Its maps drove decades of disinvestment; ERN research links historic redlining to present-day eviction and displacement patterns.

## Renter household
Category: Income & housing
See also: Eviction filing rate
A household that rents rather than owns its home — the population at risk of eviction, and the denominator for filing-rate measures. The HPRM only maps tracts with at least one renter household.

## Right to counsel
Category: Policy & protections
See also: Eviction, Just cause eviction
A policy guaranteeing tenants legal representation in eviction proceedings, where landlords are usually represented and tenants usually are not. Jurisdictions that adopt it see markedly higher rates of tenants staying housed.

## Serial filing (repeat filing)
Category: Eviction & court process
See also: Eviction filing, Eviction record
Repeated eviction filings against the same tenant at the same address, often month after month, used by some landlords as a routine rent-collection tool. Serial filings inflate filing counts and expose tenants to court costs and record damage even without a removal.

## Soft displacement
Category: Displacement & neighborhood change
See also: Hard displacement, Estimated Displacement Risk, Gentrification
Displacement through market pressure rather than a single legal event — when rising rents and neighborhood change push low-income households to leave or keep them from moving in. ERN models soft displacement with the EDR.

## Tenant protection
Category: Policy & protections
See also: Just cause eviction, Right to counsel, Notice to vacate
The body of laws and policies that shift bargaining power toward renters — rent regulation, just-cause rules, right to counsel, record sealing, and longer notice periods. ERN evaluates where such protections are strongest and weakest.

## Unlawful detainer (UD)
Category: Eviction & court process
See also: Eviction filing, Eviction
The formal legal term, in many states, for an eviction lawsuit — a landlord's court action to recover possession of a property. Court "UD" records are a primary raw source for ERN's eviction data.
