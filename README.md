# Disinformation

## tldr;
With what accuracy can a domain name be categorized as disinformation given only a domain name?

## Background
Disinformation is a severe problem and continues to accelerate due to strategic manipulation of social media algorithms<sup>[0]</sup><sup>[1]</sup><sup>[2]</sup> . Until social media companies make available more of their data, an exact understanding of the issue will remain elusive. The problem, however, is not exclusive to social media, nor is it contained to it. 

A frequent feature of disinformation campaigns involves promoting posts on social media which link to dubious shell websites pushing certain narratives, narratives with ties to foreign or domestic influence operations. These shell websites can sometimes appear to be legitimate local or national news outlets intended to deceive end users<sup>[3]</sup>. Some websites are not deceptive at all—having extremist and alarming content meant to divide and confuse<sup>[2]</sup>. In fact, the predominant strategy behind much of the content produced is to “confuse, polarize, and entrench,” with the consequence “that citizens tune out the political discourse or tune into their own, politically congenial filter bubble”.<sup>[4]</sup>

Most problematic—during the time in which this paper was authored—are influence operations that deceive on matters of public health. Common narratives of these operations include: questioning the efficacy of face masks, stoking fears about public health officials, correlating vaccinations with trans-humanist robotics (where vaccines have microchips used to control or monitor recipients), and the promotion of anti-lockdown protests.<sup>[4]</sup><sup>[5]</sup> As a report by STAT News across 93 sites publishing false harmful information about the outbreak found: “Many of their posts are being exponentially more widely shared than those from the health authorities trying to deliver real and reliable information”.<sup>[6]</sup> The dissemination of this content, and engagement with it, has undoubtedly made the COVID-19 pandemic worse. These operations are clearly working and clearly causing harm.
  
So far, there's been a bunch of attempts to solve the problem of disinformation be looking a stance detection, geometric deep learning, and a whole host of others.

## What is disinformation?
> Disinformation is defined as false information which is intended to mislead, especially propaganda issued by the media or government. Specifically, it is content meant to misinform on issues of public health, election integrity, scientific consensus, or any coordinated political propaganda effort where disinformation is not created “in good faith” (as defined by accepted rules of war).

This definition ends matters of subjectivity. It accepts information which has faced scientific scrutiny and it appeals to democratic principles, while addressing influence operations without clear attribution from the source or a formal declaration of war. The last part is probably the most important to note.

## Goal
**This project attempts to detect the likelihood of a website's participation in known influence operations by information attached to its domain name only**. Training data is comprised of the following
- A list of [fake local news](https://www.nytimes.com/2020/10/18/technology/timpone-local-news-metric-media.html) websites operated by Metric Media
- A [curated list](https://docs.google.com/document/d/10eA5-mCZLSS4MQY5QGb5ewC3VAL6pLkT53V_81ZyitM/preview) (Google Docs) by Melissa Zimdars, an assistant professor of communication at Merrimack College in Massachusetts, of known disinformation websites
- Scraped web lists (such as [this one](https://www.dailydot.com/debug/fake-news-sites-list-facebook/) from DailyDot)
- A bunch of related Kaggle datasets

**N.B.** I personally classified 25 websites as disinformation when looking at the 85 websites that ended up in the cross-section of Alexa's top 20,000 sites and a the domains generated in the data collection process. They are the following:

```
 [1] "breitbart.com"            "nypost.com"               "rt.com"                  
 [4] "thegatewaypundit.com"     "sputniknews.com"          "zerohedge.com"           
 [7] "thesun.co.uk"             "mirror.co.uk"             "theblaze.com"            
[10] "dailywire.com"            "infowars.com"             "nationalreview.com"      
[13] "pjmedia.com"              "redstate.com"             "actionnetwork.org"       
[16] "godlikeproductions.com"   "wnd.com"                  "politicususa.com"        
[19] "naturalnews.com"          "twitchy.com"              "pravda.ru"               
[22] "oann.com"                 "powerlineblog.com"        "thepoliticalinsider.com" 
[25] "collective-evolution.com"
```

Yes, you could make an argument for *some* of these. **Categorization was based on editorialization of common narratives pushed in disinformation operations**. In the the learned function ended up kicking a few of these back to me on implementation; there's room for questioning and even more room for an algorithm which more effectively defines what disinformation truly is.

## Solution
The purpose of this project is to explore the implementation of a supervised binary classification algorithm to find whether a given URL could be part of a disinformation campaign. This is a partial solution to the problem because it really only goes part of the way. It could be further implemented for a more complete solution, such as a publicly available reporting application, trust scores from visitors, *etc.*. All of this could be used to detect, track, and deter campaigns by making its results public, its data sources, and determinations transparent, and by supplying a ledger of actions taken by domain registrars in deterrence of propaganda online. 

This ledger *could* also better inform the public about the extent of the problem.

This project focuses purely on the implementation of an ML algorithm which uses OSINT about domain names in its determinations. Included within the scope of this is a curated data set composed of domain names from Alexa’s most trafficked websites, similar datasets with confirmed sources of disinformation, and other sources tracking the issue on the web. It will try tokenizing a given URL using NLP and decide whether text aligns with those used by confirmed influence operations. It will then output a decision on whether the given URL could be suspicious.

While outside the scope of this solution, the algorithm could be implemented as a part of a web interface which allows users to send suspected sources of disinformation. More to come.

## References
- [0] U.S. Department of State, 2020
- [1] 116th Congress 1st Session Senate, 2019
- [2] DiResta, 2019
- [3] Levin, 2019
- [4] Krebs, 2020
- [5] Federation of American Scientists
- [6] Gregory, 2020
