---
version: "1"
note: "초기 작성"
creator: "Claude Haiku 4.5"
created_time: "25-12-15 07:45"
---

## 압축 내용

Agile 개발은 1970년대 Waterfall 방식의 실패에서 출발하여, 2001년 Snowbird에서 17명의 전문가들이 Agile Manifesto를 작성함으로써 탄생했으며, 이는 반복적 개발과 데이터 기반 관리를 통해 소프트웨어 프로젝트의 변화에 적응하고 최고의 결과를 추구하는 철학이다. (pp.36-72)

## 핵심 내용

### Agile의 역사적 배경

소프트웨어 산업은 1970년에 두 가지 상충하는 관리 방식의 교차로에 있었다 (p.39). 하나는 Pre-Agile 방식으로 작은 단계를 취하고 측정하며 개선하는 반응형 접근법이었고, 다른 하나는 Scientific Management로 철저한 분석과 계획 후 실행하는 방식이었다. 1970년 Winston Royce의 논문이 Waterfall 다이어그램을 제시했고, 이것이 소프트웨어 업계를 지배하게 되었다 (pp.40-41). 그러나 30년간 Waterfall은 반복적인 실패를 초래했으며 (p.43), 1990년대 후반부터 XP, Scrum, Crystal 등의 가벼운 프로세스들이 등장하면서 Agile의 개혁이 시작되었다 (p.44).

### Agile Manifesto와 Snowbird 회의

2001년 2월 Snowbird에서 17명의 소프트웨어 전문가들이 모여 Agile Manifesto를 작성했다 (p.37). XP 팀, Scrum 팀, Feature-Driven Development, DSDM, Crystal 등 다양한 가벼운 프로세스를 대표하는 전문가들이 모였다 (p.47). 회의 결과 4가지 핵심 가치가 도출되었다 (p.48-49):
- Individuals and interactions over processes and tools
- Working software over comprehensive documentation
- Customer collaboration over contract negotiation
- Responding to change over following a plan

이 4가지 가치는 보완적 가치(프로세스, 도구, 문서, 계약, 계획)를 완전히 대체하지 않으면서도 우선순위를 명확히 한다 (p.48).

### Waterfall의 문제점

Waterfall 방식의 전형적인 실패 과정은 다음과 같다 (pp.54-59): 먼저 고정된 완료 날짜와 유동적인 요구사항이 공존한다 (p.54). 프로젝트는 분석, 설계, 구현 3단계로 나뉘는데, 각 단계가 일정에 따라 인위적으로 종료된다 (pp.54-59). 분석과 설계 단계에서는 불명확한 완료 기준으로 일정을 맞추지만, 구현 단계에서는 실제 코드 구현이 필요하므로 실패가 극명해진다 (p.57). 결과적으로 10월 중순에야 일정 지연을 깨닫게 되고, 이로 인해 Death March Phase가 발생한다 (pp.58-59).

### Agile의 접근 방식

Agile의 핵심은 반복적 개발과 데이터 기반 관리이다 (p.60-62). 프로젝트를 1-2주 단위의 iteration으로 나누고, 매 iteration마다 계획된 기능들을 실제로 구현한다 (p.60). Iteration Zero에서 기능 목록(stories)을 작성하고 추정하며, 이후 모든 iteration에서 분석, 설계, 구현이 연속적으로 진행된다 (pp.60-61). 각 iteration 후 실제 완료된 작업량을 측정하면, 이는 팀의 velocity를 보여주는 실제 데이터가 되고 (p.62), 이 데이터를 통해 프로젝트 완료 일정을 지속적으로 재계산할 수 있다 (pp.62-63).

### Iron Cross와 관리의 선택

Agile은 좋음, 빠름, 싼 비용, 완료라는 4가지 속성 중 3가지만 선택할 수 있다는 Iron Cross 원칙을 인정한다 (pp.50-51). 좋은 관리자는 이 4가지 속성의 계수를 조정하여 현실적인 관리를 한다 (p.51). Agile은 schedule을 고정하고 quality를 높게 유지한 상태에서, scope를 조정함으로써 프로젝트를 관리한다 (pp.64-68). 일정 변경은 비즈니스 영향이 크므로, 먼저 인력 추가를 고려하지만 Brooks' Law가 적용되고 (p.65), quality를 낮추는 것도 장기적으로 속도를 낮추므로 (p.66), 결국 scope 조정이 가장 현실적인 선택이 된다 (pp.67-68).

### Circle of Life와 XP의 Practices

Ron Jeffries의 Circle of Life는 XP의 practices를 시각화한 것이다 (p.68-70). 외부 고리는 비즈니스와의 커뮤니케이션을 담당하는 practices (Planning Game, Small Releases, Acceptance Tests, Whole Team), 중간 고리는 팀 내 커뮤니케이션을 담당하는 practices (Sustainable Pace, Collective Ownership, Continuous Integration, Metaphor), 내부 고리는 기술적 품질을 보장하는 practices (Pairing, Simple Design, Refactoring, Test Driven Development)로 구성된다 (pp.69-70). 이 practices들은 Agile Manifesto의 4가지 가치를 실현하는 구체적인 방법들이다 (pp.70-71).

## 상세 내용

- [[#Agile 이전의 역사]]
- [[#Scientific Management와 Pre-Agile의 충돌]]
- [[#Waterfall의 등장과 지배]]
- [[#Waterfall의 삼십 년 실패]]
- [[#Agile 개혁의 시작]]
- [[#Snowbird 회의의 배경]]
- [[#Snowbird의 17명]]
- [[#Agile Manifesto의 창출]]
- [[#Manifesto 이후의 작업]]
- [[#Agile의 철학]]
- [[#Iron Cross 원칙]]
- [[#Charts on the Wall]]
- [[#Agile의 데이터 기반 관리]]
- [[#Waterfall 프로젝트의 전형적 과정]]
- [[#"The Meeting"으로부터의 교훈]]
- [[#Analysis Phase의 문제점]]
- [[#Design Phase의 문제점]]
- [[#Implementation Phase의 위기]]
- [[#Death March Phase]]
- [[#Agile의 반복적 접근]]
- [[#Iteration Zero]]
- [[#계속되는 Exploration]]
- [[#실제 데이터 수집]]
- [[#Velocity와 재계산]]
- [[#Hope Versus Management]]
- [[#Schedule 변경의 어려움]]
- [[#Brooks' Law와 인력 추가]]
- [[#Quality의 중요성]]
- [[#Scope 조정]]
- [[#Business Value Order]]
- [[#Circle of Life 소개]]
- [[#외부 고리: Business Practices]]
- [[#중간 고리: Team Practices]]
- [[#내부 고리: Technical Practices]]
- [[#Practices와 Manifesto의 연결]]

### Agile 이전의 역사

Agile의 기초는 인류가 공통의 목표를 위해 협력하기 시작한 50,000년 전까지 거슬러 올라간다 (p.38). 작은 중간 목표를 설정하고 각 단계 후 진행 상황을 측정하는 개념은 인간의 본성에 너무 내재적이어서 혁명으로 간주되지 않는다 (p.38). 소프트웨어 초기 역사에서도 Alan Turing의 1936년 논문과 1946년 Automatic Computing Engine의 코드 작성, Mercury 공간 캡슐 제어 소프트웨어 개발(반일 단계로 진행) 등에서 Agile 같은 행동이 관찰된다 (pp.38, 78).

### Scientific Management와 Pre-Agile의 충돌

1880년대 Frederick Winslow Taylor가 체계화한 Scientific Management는 관리자가 최고의 절차를 과학적으로 결정하고 모든 하위자들이 그 계획을 따르게 하는 하향식 통제 방식이다 (p.39). 이는 대규모 업전인 공사(피라미드, 스톤헨지)를 가능하게 했으며 후대 산업에서 효율성을 대폭 높였다 (p.39).

반면 Pre-Agile 방식은 낮은 변화 비용과 부분적으로 정의된 문제에 효과적이었고, Scientific Management는 높은 변화 비용과 명확히 정의된 문제에 효과적이었다 (pp.39-40). 1970년 소프트웨어 프로젝트가 어느 범주에 속하는지에 대한 명시적 선택이 이루어지지 않았으며, 우연이 역사를 결정했다 (p.40).

### Waterfall의 등장과 지배

1970년 Winston Royce의 논문은 대규모 소프트웨어 프로젝트 관리를 설명했는데, 논문의 다이어그램이 실제로는 Royce가 제시한 straw man일 뿐 그의 권장사항이 아니었다 (p.40-41). 그러나 다이어그램이 물이 바위를 흘러내려가는 것처럼 보여서 "Waterfall"이라는 이름이 붙었고, 소프트웨어 업계는 이것을 Scientific Management의 현대판으로 채택했다 (p.41).

Waterfall은 철저한 분석, 상세한 계획 수립, 계획 실행을 중심으로 한다 (p.41). 구조화된 분석/설계, 객체지향 분석/설계 등 새로운 패러다임이 등장할 때마다 Waterfall의 3단계 패턴이 자동으로 따라왔다 (p.43). 개발자들이 이 패턴의 지배를 받았던 이유는 30년간 철저히 분석하고 설계했는데도 구현 단계에서 실패했기 때문에, 그 원인이 전략이 아니라 실행에 있다고 잘못 생각했기 때문이다 (p.43-44).

### Waterfall의 삼십 년 실패

저자가 1970년 18세 어린 프로그래머였을 때, 프로그램은 천공 카드에 작성되고 컴퓨터 연산자가 처리하는 방식이었다 (pp.42-43). 그러나 자신의 팀은 전담 미니컴퓨터를 사용하여 하루에 여러 번 테스트할 수 있었고, 이는 구조 없는 코드-수정의 반복이었다 (p.43).

1972년경 Waterfall을 읽은 저자는 이것이 "기적 같은" 해결책이라고 믿었다 (p.43). 문제를 미리 분석하고 설계한 후 구현하면, 각 단계가 전체 프로젝트의 1/3씩 소요될 것이라 예상했다 (p.43). 그러나 30년간 반복된 시도는 모두 실패했으며, 꼼꼼히 계획한 내용이 구현 단계에서 부분적으로 무의미해졌다 (p.43). 이 실패에도 불구하고 개발자들은 Waterfall 자체가 아니라 자신의 능력을 의심했다 (p.44).

### Agile 개혁의 시작

1980년대 후반과 1990년대 초반부터 Agile 개혁이 시작되었다 (p.44). Smalltalk 커뮤니티의 신호, Booch의 1991년 저서, Cockburn의 Crystal Methods (1991), 디자인 패턴 커뮤니티의 논의(1994), Coplien의 논문 (1995), Beedle 등의 Scrum 논문 (1995)이 순차적으로 나타났다 (p.44).

1999년 Munich OOP 컨퍼런스에서 저자는 Kent Beck을 만났고, Beck의 Extreme Programming(XP) 저작에 매료되어 lunch를 함께했다 (p.45). 저자가 운영하던 Object Mentor 회사는 Beck과 파트너십을 형성하여 XP Immersion 부트캠프를 제공했고, 1999년 말부터 2001년 9월까지 수백 명을 교육했다 (p.45).

2000년 여름, Beck은 XP와 Pattern 커뮤니티의 quorum을 자신의 집 근처에서 "XP Leadership" 회의에 소집했다 (p.45). 회의에서 XP 주변 비영리 단체 설립을 제안했으나 반대가 있었다 (p.46). 저자는 Martin Fowler를 만나 더 광범위한 가벼운 프로세스 advocate들을 모아서 manifesto를 만들자는 아이디어를 제안했다 (p.46). Fowler와 저자가 2000년 가을 Chicago의 coffee shop에서 만나 manifesto 아이디어를 다듬고 초대장을 작성했다 (p.46). Alistair Cockburn은 비슷한 회의를 계획 중이었으나, 저자들의 초대장 목록이 더 낫다고 생각하여 Snowbird 스키 리조트에서 회의를 열기로 제안했다 (p.46).

### Snowbird 회의의 배경

Snowbird 회의는 "The Light Weight Process Summit"이라는 제목으로 예정되었는데, 누가 이런 이름의 회의에 참석하겠는가라는 의문이 들 정도로 주목받지 않을 것으로 예상되었다 (p.46). 그러나 17명의 전문가들이 참석하겠다고 응했으며, 이들은 Snowbird Lodge의 Aspen 방에 모였다 (p.46).

참석자들이 17명의 "중년 백인 남성"이라는 비판이 있었으나, 당시 소프트웨어 senior programmer의 대다수가 이 범주에 속했다 (p.46-47). 실제로 Agneta Jacobson 여성이 초대되었으나 참석할 수 없었다 (p.47).

### Snowbird의 17명

참석자들은 5가지 다른 가벼운 프로세스를 대표했다 (p.47). XP 팀은 Kent Beck, 저자(Bob Martin), James Grenning, Ward Cunningham, Ron Jeffries였다 (p.47). Scrum 팀은 Ken Schwaber, Mike Beedle, Jeff Sutherland였다 (p.47). Jon Kern은 Feature-Driven Development, Arie van Bennekum은 Dynamic Systems Development Method (DSDM), Alistair Cockburn은 Crystal 방법들을 각각 대표했다 (p.47).

나머지는 상대적으로 특정 프로세스와 관련 없었다 (p.47). Andy Hunt와 Dave Thomas는 Pragmatic Programmers, Brian Marick는 testing consultant, Jim Highsmith는 software management consultant였다 (p.47). Steve Mellor은 Model-Driven 철학을 대표하여 나머지 참석자들의 의견 균형을 맞추려 했고, Martin Fowler는 XP 팀과 친근했지만 특정 branded process에는 회의적이었다 (p.47).

### Agile Manifesto의 창출

저자의 회상이 거의 20년 전이고, 다른 참석자들의 기억과 다르므로, 세부 사항은 정확하지 않을 수 있다 (p.47). 저자가 회의를 시작했고, 미션은 이 다양한 가벼운 프로세스들의 공통점을 설명하는 manifesto를 만드는 것이어야 한다고 제안했다 (p.47).

표준적인 회의 방식으로 카드에 이슈를 적고 floor에서 affinity grouping으로 정렬했다 (p.47-48). 첫째 날 말쯤에 magical moment가 발생했으며, 4가지 값이 whiteboard에 쓰여졌다 (p.48). 이들은 개인과 상호작용, 작동하는 소프트웨어, 고객 협력, 변화에 대한 반응이었다 (p.48). Ward Cunningham(또는 Martin Fowler의 기억으로는 Martin)이 이들이 "선호되지만 보완적 가치를 대체하지 않는다"는 아이디어를 제안했다 (p.48).

Manifesto 아이디어가 형성되자 전체 그룹이 결집했다 (p.48). 약간의 wordsmithing과 tweaking이 있었지만, Ward가 preamble "We are uncovering better ways of developing software by doing it and helping others do it"를 작성했고 (p.48), 이에 대한 토론이나 반대 없이 합의가 도출되었다 (p.48).

최종 Agile Manifesto는 4개 문장으로 구성되었다 (p.49):
- Individuals and interactions over processes and tools.
- Working software over comprehensive documentation.
- Customer collaboration over contract negotiation.
- Responding to change over following a plan.

"Agile"이라는 이름은 slam dunk가 아니었다 (p.49). "Light Weight"가 더 낫다고 생각한 사람도 있었으나 "inconsequential"을 함축할 수 있었다 (p.49). "Adaptive"를 좋아하는 사람도 있었고, "Agile"이 군대에서 유행하는 buzzword라는 언급도 있었으나, 결국 "Agile"이 "나쁜 대안들 중 최선"이 되었다 (p.49).

회의 둘째 날이 끝나갈 때, Ward는 agilemanifesto.org 웹사이트를 만들 것을 자청했다 (p.49). 사람들이 이에 서명하게 하는 것이 그의 아이디어였다 (p.49).

### Manifesto 이후의 작업

Snowbird 이후 2주는 4가지 가치만으로는 충분하지 않다는 합의에 따라 principles document를 작성하는 힘든 작업이 이루어졌다 (p.50). 4가지 가치는 모든 사람이 동의하면서도 실제 작동 방식을 바꾸지 않는 "엄마와 애플파이" 같은 명제이므로, principles는 그 가치들이 실제 결과를 초래함을 명확히 해야 했다 (p.50). 여러 번의 이메일 왕복과 wordsmithing을 거친 후, 참석자들은 자신의 일상으로 돌아갔다 (pp.50-51).

저자를 포함한 참석자들은 이것이 끝이라고 예상했다 (p.51). 그러나 그 이후의 엄청난 지지가 뒤따랐으며, 그 2일이 얼마나 중요했는지 아무도 예상하지 못했다 (p.51). Alistair도 비슷한 회의를 소집하려 했을 것이므로, 다른 그룹도 비슷할 가능성이 있다 (p.51).

### Agile의 철학

소프트웨어 프로젝트를 어떻게 관리할 것인가? (p.50) 여러 접근법이 있었지만 대부분 좋지 않았다 (p.50). 그 중 일부는 "희망과 기도" 또는 채찍, 쇠사슬, 끓는 기름과 같은 motivational techniques였다 (p.50-51). 이들은 거의 보편적으로 소프트웨어 mismanagement의 특성 증상을 초래했다 (p.51). 개발 팀들이 항상 늦었고, 품질이 낮았으며, 고객의 필요를 충족하지 못했다 (p.51).

### Iron Cross 원칙

이 관리 기법들이 실패하는 이유는 소프트웨어 프로젝트의 기본 물리학을 이해하지 못하기 때문이다 (p.50). 이 물리학은 모든 프로젝트를 project management의 "Iron Cross"라고 하는 피할 수 없는 trade-off를 따르도록 제약한다 (p.50). Good, Fast, Cheap, Done: 4가지 중 3가지만 선택할 수 있다 (p.50).

좋고 빠르고 싼 프로젝트는 완료되지 않는다 (p.50-51). 완료되고 싼 빠른 프로젝트는 좋지 않다 (p.50-51). 현실은 좋은 project manager가 이 4가지 속성의 계수를 이해하고 관리한다는 것이다 (p.51). 좋은 관리자는 모든 계수가 100%이기를 요구하지 않고, 충분히 좋고, 충분히 빠르고, 충분히 싸고, 필요한 만큼 완료되도록 관리한다 (p.51).

Agile은 이러한 실용적인 project management를 가능하게 하는 framework이다 (p.51). 그러나 이 관리는 자동화되지 않으며, 관리자가 적절한 결정을 내린다는 보장이 없다 (p.51-52). Agile framework 내에서도 프로젝트를 완전히 mismanage하고 실패로 몰 수 있다 (p.52).

### Charts on the Wall

Agile이 이런 관리를 어떻게 지원하는가? (p.52) Agile은 데이터를 제공한다 (p.52). Agile 개발 팀은 관리자가 좋은 결정을 내리기 위해 필요한 정보를 생산한다 (p.52).

첫 번째 차트는 개발 팀이 매주 얼마나 많은 작업을 완료했는지를 보여주는 velocity chart이다 (p.52). 측정 단위는 "points"이고 (p.52), 일반인이 몇 초 만에 보면 팀이 얼마나 빠르게 움직이는지를 알 수 있다 (p.52). 평균 velocity가 주당 약 45 points라면, 다음 주에도 약 45 points를 완료할 것을 예측할 수 있다 (p.52). 다음 10주에서 약 450 points를 완료해야 한다면, 이것은 강력하다 (p.52). 팀과 관리자가 프로젝트의 points 수를 파악하면 더욱 강력하다 (p.52).

두 번째 차트는 burn-down chart인데, 다음 주요 milestone까지 남은 points가 몇 개인지를 보여준다 (pp.52-53). 매주 감소하지만, velocity chart의 감소보다는 적은 양이 감소하는데, 이는 개발 중에 지속적으로 발견되는 새로운 요구사항과 문제 때문이다 (p.53).

Burn-down chart의 slope는 milestone에 도달할 시기를 예측한다 (p.53). 거의 모든 사람이 이 2개 차트를 보고 주당 45 points의 속도로 6월에 milestone에 도달할 것이라고 결론지을 수 있다 (p.53).

2월 17일의 glitch는 새로운 기능 추가나 요구사항의 주요 변화로 인한 것일 수 있으며, 또는 개발자들이 남은 작업을 다시 추정한 결과일 수 있다 (p.53). 어느 경우든 일정에 미치는 영향을 알고 싶으므로 프로젝트가 적절히 관리될 수 있다 (p.53).

Agile의 중요한 목표는 이 2개 차트를 wall에 게시하는 것이다 (p.53). Agile 소프트웨어 개발의 주요 추동력 중 하나는 project를 관리하기 위해 manager들이 필요한 데이터를 제공하는 것이다 (p.53).

### Agile의 데이터 기반 관리

많은 사람들이 이전 단락에 동의하지 않을 것이다 (p.53). 결국 차트는 Agile Manifesto에 언급되지 않으며, 모든 Agile 팀이 이러한 차트를 사용하지는 않는다 (p.53). 공정하게 말하면, 중요한 것은 차트 자체가 아니라 데이터이다 (p.53).

Agile 개발은 무엇보다도 feedback-driven 접근법이다 (p.54). 매주, 매일, 매시간, 심지어 매분마다 이전 주, 일, 시간, 분의 결과를 보고 적절한 조정을 한다 (p.54). 이것은 개별 programmer에게도 적용되고, 전체 팀의 관리에도 적용된다 (p.54). 데이터 없이는 프로젝트를 관리할 수 없다 (p.54).

따라서 wall에 차트를 게시하지 않더라도 데이터를 manager들 앞에 놓아야 한다 (p.54). Manager들이 팀의 속도와 완료해야 할 작업의 양을 알아야 하고, 이 정보를 transparent, public, obvious한 방식으로 제시해야 한다 (p.54).

왜 이 데이터가 중요한가? 데이터 없이 프로젝트를 효과적으로 관리할 수 있는가? (p.54-55) 30년을 시도했고 실패했다 (p.55).

### Waterfall 프로젝트의 전형적 과정

프로젝트에서 가장 먼저 알게 되는 것은 무엇인가? (p.55) 프로젝트의 이름이나 요구사항을 알기 전에, 한 가지 정보가 모든 다른 정보보다 먼저 온다 (p.55). The Date이다 (p.55). Date가 정해지면, The Date는 frozen된다 (p.55).

Date를 협상할 이유가 없다 (p.55). Date는 좋은 비즈니스 이유로 선택된다 (p.55). 9월에 trade show가 있거나, 주주 회의가 있거나, 펀딩이 끝나거나 할 수 있다 (p.55). 어떤 이유든 비즈니스 이유는 좋은 이유이며, 몇몇 개발자가 완료할 수 없을 것 같다는 이유로 변하지 않는다 (p.55).

동시에, 요구사항은 wildly in flux이며 절대 frozen될 수 없다 (p.55). 고객들은 실제로 원하는 것을 모르며, 문제 해결을 원하는 것을 시스템의 요구사항으로 번역하는 것은 trivial하지 않다 (p.55). 요구사항은 지속적으로 재평가되고 재생각된다 (p.55). 새로운 기능이 추가되고, 기존 기능이 제거된다 (p.55). UI는 주 단위 또는 일 단위로 형태가 바뀐다 (p.55).

이것이 소프트웨어 개발 팀의 세상이다 (p.55). Date는 frozen되고 요구사항은 지속적으로 변한다 (p.55). 이 환경에서 개발 팀은 프로젝트를 좋은 결과로 몰아가야 한다 (p.55).

### "The Meeting"으로부터의 교훈

Waterfall 모델은 이 문제를 해결하는 방법을 약속했다 (p.55). 이것이 얼마나 매혹적이고 비효율적인지 이해하려면, "The Meeting"을 살펴봐야 한다 (p.55).

5월 1일이다 (p.55). 큰 boss가 우리 모두를 conference room으로 불렀다 (p.55). "We've got a new project," the big boss says. "It's got to be done November first. We don't have any requirements yet. We'll get them to you in the next couple of weeks." (p.55)

"Now, how long will it take you to do the analysis?" (p.55-56) 우리는 서로 눈을 마주친다 (p.56). 아무도 말하려고 하지 않는다 (p.56). 이런 질문에 어떻게 답할 수 있는가? (p.56) 우리 중 한 명이 "But we don't have any requirements yet"이라고 중얼거린다 (p.56).

"Pretend you have the requirements!" boss가 외친다 (p.56). "You know how this works. You're all professionals. I don't need an exact date. I just need something to put in the schedule. Keep in mind if it takes any more than two months we might as well not do this project." (p.56)

"Two months?"이 누군가의 입에서 나온다 (p.56). 하지만 boss는 이것을 affirmation으로 받아들인다 (p.56). "Good! That's what I thought too. Now, how long will it take you to do the design?" (p.56)

다시 놀라운 침묵이 방을 채운다 (p.56). 수학을 한다 (p.56). 11월 1일까지 6개월이 있다 (p.56). 결론은 명백하다 (p.56). "Two months?"이라고 말한다 (p.56).

"Precisely!" Big Boss가 활짝 웃으며 답한다 (p.56). "Exactly what I thought. And that leaves us two months for the implementation. Thank you for coming to my meeting." (p.56)

많은 독자들이 이 회의에 참석했을 것이다 (p.56). 그렇지 않은 분들은 자신을 운 좋은 사람이라고 여기길 바란다 (p.56).

### Analysis Phase의 문제점

conference room을 나가 사무실로 돌아간다 (p.56). 무엇을 하고 있는가? (p.56) 이것이 Analysis Phase의 시작이므로, 분석해야 한다 (p.56). 하지만 "분석"이라는 것이 정확히 무엇인가? (p.56)

software analysis에 관한 책을 읽으면, 분석에 대한 정의는 저자만큼 많다 (p.57). 분석이 정확히 무엇인지에 대한 진정한 합의는 없다 (p.57). 요구사항의 work breakdown structure 생성, 요구사항의 발견과 정교화, 기본 data model 또는 object model의 생성 또는 … (p.57) 분석의 최고의 정의는 "It's what analysts do"이다 (p.57).

물론 명백한 것들이 있다 (p.57). 프로젝트 사이징, 기본 feasibility와 인적 자원 예측을 수행해야 한다 (p.57). 일정이 달성 가능한지 확인해야 한다 (p.57). 분석이 무엇이든, 우리가 다음 2개월 동안 할 일이다 (p.57).

이것이 프로젝트의 honeymoon phase이다 (p.57). 모두 happily 웹을 서핑하고, day-trading을 하고, 고객을 만나고, 사용자를 만나고, 좋은 다이어그램을 그리며 일반적으로 멋진 시간을 보내고 있다 (p.57).

그러다 7월 1일에 기적이 일어난다 (p.57). 분석이 완료된다 (p.57). 왜 분석이 완료되었는가? (p.57) 7월 1일이 왔기 때문이다 (p.57). 일정에 따르면 7월 1일에 완료되어야 하므로, 왜 늦을까? (p.57)

작은 파티를 연다 (p.57). 풍선과 연설이 있고, phase gate를 통과하고 Design Phase에 입장했음을 축하한다 (p.57).

### Design Phase의 문제점

이제 무엇을 하는가? (p.57) 물론 설계를 한다 (p.57). 하지만 설계가 정확히 무엇인가? (p.57)

software design에 대해 좀 더 많은 resolution이 있다 (p.57-58). Software design은 프로젝트를 modules로 나누고 이들 modules 간 interfaces를 설계하는 곳이다 (p.58). 필요한 teams의 개수와 teams 간 connections를 고려하는 곳이기도 하다 (p.58). 일반적으로 현실적으로 달성 가능한 implementation plan을 생산하기 위해 일정을 refine한다 (p.58).

물론 이 phase 중에 예상 밖의 변화가 발생한다 (p.58). 새로운 기능이 추가되고, 기존 기능이 제거되거나 변경된다 (p.58). 이 변화들을 다시 분석하고 싶지만 시간이 짧다 (p.58). 이 변화들을 설계에 hack한다 (p.58).

그리고 또 다른 기적이 일어난다 (p.58). 9월 1일이고, 설계가 완료된다 (p.58). 왜 설계가 완료되었는가? (p.58) 9월 1일이 완료 예정일이기 때문이다 (p.58). 그러면 왜 늦을까? (p.58)

또 다른 파티 (p.58). 풍선과 연설 (p.58). Phase gate를 통과하고 Implementation Phase로 blast한다 (p.58).

이를 한 번 더 뽑아낼 수 있으면 좋겠다 (p.58). 단지 구현이 완료되었다고 말하고 끝났으면 좋겠다 (p.58). 하지만 그럴 수 없다 (p.58). 구현이라는 것의 문제는 그것이 실제로 완료되어야 한다는 것이다 (p.58). 분석과 설계는 binary deliverables이 아니다 (p.58). 명확하지 않은 완료 기준이 없다 (p.58). 완료된 시점을 정확히 알 방법이 없다 (p.58). 그러므로 일정대로 완료된 것이라고 말할 수도 있다 (p.58).

### Implementation Phase의 위기

반면 구현은 명확한 완료 기준이 있다 (p.58-59). 성공적으로 그것이 완료되었다고 가짜로 주장할 방법이 없다 (p.59).

구현 phase 중에 무엇을 하고 있는지는 완전히 명확하다 (p.59). 코딩을 하고 있다 (p.59). 이미 4개월을 낭비했으므로 미친 듯이 코딩을 해야 한다 (p.59).

한편, 요구사항은 여전히 변하고 있다 (p.59). 새로운 기능이 추가되고, 기존 기능이 제거되거나 변경된다 (p.59). 이런 변화들을 다시 분석하고 설계하고 싶지만, 남은 기간은 몇 주뿐이다 (p.59). 코드에 hack, hack, hack한다 (p.59).

코드를 보고 설계와 비교하면서 설계할 때 뭔가 특별한 것을 피웠을 것 같은 깨달음이 온다 (p.59). 코드는 그 멋진 다이어그램들처럼 나오지 않는다 (p.59). 그런데 시간이 표를 누르고 있고 overtime hours이 쌓이고 있으므로 그것을 걱정할 시간이 없다 (p.59).

그리고 10월 15일 경에, 누군가가 "Hey, what's the date? When is this due?"라고 말한다 (p.59). 그 순간 우리는 단 2주밖에 남지 않았으며 11월 1일까지 절대 완료하지 못할 것이라는 깨달음이 온다 (p.59). 이것이 또한 stakeholders가 이 project에 작은 문제가 있을 수도 있다는 이야기를 들은 첫 번째 시간이다 (p.59).

stakeholders의 불안감을 상상할 수 있다 (p.59). "Couldn't you have told us this in the Analysis Phase? Isn't that when you were supposed to be sizing the project and proving the feasibility of the schedule? Couldn't you have told us this during the Design Phase? Isn't that when you were supposed to be breaking up the design into modules, assigning those modules to teams, and doing the human resources projections? Why'd you have to tell us just two weeks before the deadline?" (pp.59-60)

그리고 그들은 맞다 (p.60).

### Death March Phase

이제 project의 Death March Phase로 들어간다 (p.60). 고객이 화났다 (p.60). Stakeholders가 화났다 (p.60). 압박이 증가한다 (p.60). Overtime이 급증한다 (p.60). 사람들이 나간다 (p.60). 지옥이다 (p.60).

3월 어딘가에서, 고객이 원하는 것을 sort of half 하는 limp한 무언가를 deliver한다 (p.60). 모두가 upset하다 (p.60). 모두가 demotivated하다 (p.60). 우리는 다시 이런 project를 절대 하지 않겠다고 약속한다 (p.60).

이것을 "Runaway Process Inflation"이라고 부른다 (p.60). 우리는 작동하지 않은 것을 다시 할 것이고, 많이 더 할 것이다 (p.60).

### Waterfall의 현실성

명확하게 그 이야기는 과장된 것이다 (p.60). 그것은 거의 모든 소프트웨어 project에서 일어난 거의 모든 나쁜 일을 한 곳에 모았다 (p.60). 대부분의 Waterfall projects는 그렇게 spectacularly 실패하지는 않았다 (p.60). 실제로 일부는 순수한 운을 통해 modest한 성공으로 마무리되었다 (p.60). 반면에, 저자는 그 회의에 한 번 이상 참석했으며, 그런 project들에 여러 번 작업했으며, 혼자가 아니다 (p.60). 그 이야기는 과장되었으나 여전히 현실이었다 (p.60).

Waterfall projects가 위에 설명된 것처럼 재앙적이었다면 몇 개나 될까? (p.60) 저자는 상대적으로 적다고 말해야 한다 (p.60). 반면에, zero는 아니고, 너무 많다 (p.60). 더욱이, vast majority는 더 적거나 더 큰 정도로 비슷한 문제를 겪었다 (p.60).

Waterfall은 절대적 재앙이 아니었다 (p.60). 모든 소프트웨어 project를 rubble로 압축하지 않았다 (p.60). 하지만 그것은, 그리고 여전히 software project를 실행하는 재앙적인 방식이었다 (p.60).

### Agile의 반복적 접근

더 나은 방법이 있는가? (p.60) Waterfall idea의 것은 단지 많은 의미를 만든다 (p.60). 먼저, 우리는 문제를 분석하고, 그 다음 우리는 그 문제에 대한 해결책을 설계하고, 그 다음 우리는 그 설계를 구현한다 (p.60).

단순 (p.60). 직접적 (p.60). 명백 (p.60). 그리고 틀렸다 (p.60).

Agile project에 대한 접근은 방금 읽은 것과 완전히 다르지만, 동등한 의미를 만든다 (p.60). 실제로, 이것을 읽으면서 당신은 이것이 Waterfall의 3 phases보다 훨씬 더 의미 있다는 것을 깨달을 것이다 (pp.60-61).

Agile project는 analysis로 시작하지만, 끝나지 않는 analysis이다 (p.61). Figure 1.4 다이어그램에서 우리는 whole project를 본다 (p.61). 오른쪽에는 end date인 11월 1일이 있다 (p.61). 첫 번째로 알게 되는 것이 date임을 기억하라 (p.61). 우리는 이 시간을 "iterations" 또는 "sprints"라고 불리는 regular increments로 subdivide한다 (p.61).

Sprint는 Scrum에서 사용하는 용어이며, 저자는 이 용어를 싫어한다 (p.61). "Sprint"는 가능한 한 빠르게 달리는 것을 함축하기 때문이다 (p.61). 소프트웨어 project는 marathon이며, marathon에서 sprint하고 싶지 않다 (p.61).

iteration의 크기는 일반적으로 1 또는 2주이다 (p.61). 저자는 너무 많은 것이 2주에 잘못될 수 있으므로 1주를 prefer한다 (p.61). 다른 사람들은 2주를 prefer하는데, 1주에 충분한 것을 완료할 수 없을 것을 두려워한다 (p.61).

### Iteration Zero

첫 번째 iteration을 "Iteration Zero"라고 부르기도 한다 (p.61). 단기 기능 목록을 생성하는 데 사용되며, 이를 "stories"라고 한다 (p.61). 나중에 이것에 대해 훨씬 더 이야기할 것이므로, 지금은 이를 개발해야 할 기능으로 생각하면 된다 (p.61).

Iteration Zero는 또한 개발 환경을 설정하고, stories를 추정하고, 초기 계획을 수립하는 데 사용된다 (p.61). 그 계획은 simply 처음 몇 iterations에 stories를 할당한 tentative allocation이다 (p.61). 마지막으로, Iteration Zero는 개발자와 architects가 tentative stories list에 기반하여 system의 initial tentative design을 창조하는 데 사용된다 (p.61-62).

### 계속되는 Exploration

stories를 쓰고, 추정하고, 계획하고, 설계하는 이 과정은 결코 멈추지 않는다 (p.62). 이것이 이유로 전체 project에 걸쳐 "Exploration"이라는 horizontal bar가 있다 (p.62). project 시작부터 끝까지 모든 iteration에서 일부 분석, 설계, 구현이 있을 것이다 (p.62).

Agile project에서는 항상 분석하고 설계한다 (p.62). 일부는 이것을 Agile이 단지 mini-Waterfalls의 시리즈라는 것을 의미한다고 해석한다 (p.62). 그렇지 않다 (p.62). Iterations는 3 섹션으로 subdivide되지 않는다 (p.62). Analysis는 iteration의 시작에만 수행되지 않으며, iteration의 끝도 solely implementation이 아니다 (p.62). 오히려 requirements analysis, architecture, design, implementation의 활동들은 iteration 전체에 걸쳐 continuous하다 (p.62).

이것을 혼동스럽다면, 걱정하지 말자 (p.62). 나중에 이것에 대해 훨씬 더 많이 이야기할 것이다 (p.62). 그냥 iterations가 Agile project의 가장 작은 granule이 아니라는 것을 기억하자 (p.62). 더 많은 levels이 있다 (p.62). 그리고 analysis, design, implementation은 이 각각의 levels에서 발생한다 (p.62). It's turtles all the way down이다 (p.62).

### 실제 데이터 수집

Iteration one은 완료할 stories 수의 추정으로 시작한다 (p.62). 팀은 그 iteration의 기간 동안 이 stories를 완료하는 데 작업한다 (p.62). 나중에 iteration 내에서 무엇이 일어나는지에 대해 이야기할 것이다 (p.62). 지금 당신이 생각하는 것은, 팀이 계획한 stories를 모두 완료할 확률이 얼마나 될까 하는 것이다 (p.62).

거의 영(0)이다 (p.62). 이것은 software가 reliably estimable process가 아니기 때문이다 (p.62). 프로그래머들은 단순히 무엇이 얼마나 걸릴지 모른다 (p.62). 이것은 우리가 incompetent하거나 lazy하기 때문이 아니다 (p.62). 이것은 task가 engaged되고 완료될 때까지 task가 얼마나 복잡할지 알 방법이 없기 때문이다 (p.62). 하지만, 보겠지만, 모든 것이 손실되지는 않는다 (p.62).

iteration 끝에서, 완료하려고 했던 stories의 일부 fraction이 완료될 것이다 (p.62). 이것은 우리의 첫 번째 측정값으로 iteration에 얼마나 많은 것이 완료될 수 있는지를 제공한다 (p.62). 이것은 실제 데이터이다 (p.62). 모든 iteration이 비슷할 것이라고 가정하면, 우리는 그 데이터를 사용하여 우리의 원래 계획을 조정하고 project의 새로운 end date를 계산할 수 있다 (pp.62-63).

이 계산은 매우 실망스러울 가능성이 높다 (p.63). 그것은 거의 확실히 원래 project end date를 상당한 계수로 초과할 것이다 (p.63). 반면에, 이 새로운 날짜는 실제 데이터에 기반하므로 무시해서는 안 된다 (p.63). 그것도 아직 너무 진지하게 받아들여져서는 안 된다 (p.63). 그것은 단일 data point에 기반하므로, 그 projected date 주변의 error bars는 상당히 넓다 (p.63).

이 error bars를 좁히려면 2 또는 3개의 더 많은 iterations를 수행해야 한다 (p.63). 할 때, 우리는 iteration에서 할 수 있는 stories 수에 대한 더 많은 data를 얻는다 (p.63). 우리는 이 수가 iteration에서 iteration으로 변한다는 것을 발견할 것이다 (p.63). 하지만 상대적으로 stable한 velocity에서 평균한다 (p.63). 4 또는 5 iterations 후, 우리는 이 project가 언제 완료될지에 대한 훨씬 나은 아이디어를 갖는다 (p.63).

iterations가 진행됨에 따라, error bars는 원래 date가 성공할 가능성이 있는지를 hope하는 데 포인트가 없을 때까지 shrink한다 (p.63).

### Hope Versus Management

이 hope의 손실은 Agile의 주요 목표이다 (p.63). 우리는 Agile을 실행하여 그 hope이 project를 죽이기 전에 그것을 파괴한다 (p.63). Hope는 project killer이다 (p.63). Hope는 소프트웨어 팀이 실제 진행 상황에 대해 manager들에게 잘못된 정보를 제공하게 한다 (p.63-64).

manager가 팀에게 "How's it going?"이라고 물을 때, 그것은 hope이 답한다: "Pretty good." (p.64) Hope는 소프트웨어 project를 관리하는 매우 나쁜 방식이다 (p.64).

Agile은 hope를 차갑고 hard reality로 대체하는 초기의 연속적인 dose를 제공하는 방식이다 (p.64).

일부 사람들은 Agile이 빠르게 가는 것이라고 생각한다 (p.64). 그렇지 않다 (p.64). 그것은 결코 빠르게 가는 것에 관한 것이 아니었다 (p.64). Agile은 우리가 얼마나 망쳤는지를 가능한 한 빨리 아는 것에 관한 것이다 (p.64). 우리가 이것을 가능한 한 빨리 알고 싶은 이유는 우리가 상황을 관리할 수 있도록 하기 위함이다 (p.64). 보겠지만, 이것이 managers가 하는 것이다 (p.64).

Managers는 데이터를 수집하고 그 데이터에 기반하여 할 수 있는 최고의 결정들을 내음으로써 소프트웨어 projects를 관리한다 (pp.64-65). Agile은 데이터를 생산한다 (p.65). Agile은 많은 데이터를 생산한다 (p.65). Managers는 그 데이터를 사용하여 project를 가능한 최고의 결과로 몰아간다 (p.65).

최고의 가능한 결과는 종종 원래 원하는 결과가 아니다 (p.65). 최고의 가능한 결과는 project를 위탁한 stakeholders에게 매우 실망스러울 수 있다 (p.65). 하지만 최고의 가능한 결과는 정의상 그들이 얻을 수 있는 최고의 것이다 (p.65).

### Schedule 변경의 어려움

이제 project management의 Iron Cross로 돌아간다 (p.65). Good, fast, cheap, done. project가 생산한 데이터가 주어지면, 그 project의 managers가 결정할 차례이다 (p.65). Project가 얼마나 좋고, 얼마나 빠르고, 얼마나 싸고, 얼마나 완료되어야 하는가? (p.65)

Managers는 scope, schedule, staff, quality를 변경함으로써 이를 수행한다 (p.65).

Schedule을 변경하는 것으로 시작하자 (p.65). Stakeholders에게 project를 11월 1일에서 3월 1일로 연기할 수 있는지 물어보자 (p.65). 이 대화들은 일반적으로 잘 진행되지 않는다 (p.65). Date가 좋은 비즈니스 이유로 선택되었음을 기억하자 (p.65). 그 비즈니스 이유들은 아마도 변하지 않았을 것이다 (p.65). 따라서 지연은 종종 비즈니스가 어떤 종류의 상당한 hit를 받을 것을 의미한다 (p.65-66).

반면에, 비즈니스가 단순히 convenience를 위해 date를 선택하는 경우가 있다 (p.66). 예를 들어, 11월에 trade show가 있어서 project를 전시하고 싶을 수도 있다 (p.66). 어쩌면 3월에 다른 trade show가 있어서 동등하게 좋을 것이다 (p.66). 기억하자, 아직 초반이다 (p.66). 우리는 이 project의 단지 몇 iterations 도입했을 뿐이다 (p.66). 우리는 stakeholders에게 우리의 delivery date가 3월이 될 것이라고 11월 show에서 booth space를 사기 전에 이야기하고 싶다 (p.66).

많은 해 전에, 저자는 전화 회사를 위해 일하는 소프트웨어 개발자 그룹을 관리했다 (p.66). project 한가운데서, 우리가 expected delivery date를 6개월 만에 놓칠 것이 명확해졌다 (p.66). 우리는 가능한 한 일찍 전화 회사 executives와 대면했다 (p.66-67). 이 executives들은 소프트웨어 팀이 초반에 일정 지연을 말한 적이 없었다 (p.67). 그들은 일어서서 우리에게 standing ovation을 주었다 (p.67).

당신은 이것을 예상해야 하지 않는다 (p.67). 하지만 우리에게 일어났다 (p.67). 한 번 (p.67).

### Brooks' Law와 인력 추가

일반적으로, 비즈니스는 단순히 schedule을 변경할 의향이 없다 (p.67). Date가 좋은 비즈니스 이유로 선택되었으며, 그 이유들은 여전히 유지된다 (p.67). 그래서 staff를 추가해 보자 (p.67). 모든 사람이 staff를 두 배로 하면 두 배 빠르게 갈 수 있다는 것을 안다 (p.67).

실제로, 이것은 정확히 케이스의 반대이다 (p.67). Brooks' Law는: Adding manpower to a late project makes it later. (p.67)

실제로 일어나는 것은 Figure 1.7의 다이어그램과 같다 (p.67). 팀은 일정 productivity에서 일하고 있다 (p.67). 그 다음 new staff가 추가된다 (p.67). Productivity는 몇 주 동안 plummets한다 (p.67). New people이 old people의 life를 빨아낸다 (p.67). 그 다음, hopefully, new people들이 충분히 똑똑해져서 실제로 contribute를 시작한다 (p.67).

managers가 하는 gamble은 그 curve 아래의 area가 net positive일 것이라는 것이다 (p.67). 물론 충분한 시간과 충분한 개선이 필요하여 초기 손실을 make up한다 (p.67).

또 다른 요소는, 물론, staff를 추가하는 것이 비싸다는 것이다 (p.67). 종종 budget은 단순히 새로운 사람들을 고용하는 것을 tolerate할 수 없다 (p.67). 따라서 이 논의의 목적상, staff를 증가시킬 수 없다고 가정하자 (p.67). 이것은 변경할 다음 것이 quality라는 것을 의미한다 (p.67).

### Quality의 중요성

모든 사람이 crap을 생산함으로써 훨씬 빠르게 갈 수 있다는 것을 안다 (p.67). 그래서 모든 tests를 멈추고, 모든 code reviews를 멈추고, 모든 refactoring nonsense를 멈추고, just 코드를 해라 (p.67-68). 필요하다면 주당 80시간을 code하지만, just 코드를 해라! (p.68)

저자는 당신에게 이것이 futile하다고 말할 것이라는 것은 확실하다 (p.68). Crap을 생산하는 것은 당신을 빠르게 가게 하지 않으며, 그것은 당신을 느리게 가게 한다 (p.68). 이것은 프로그래머로서 20 또는 30년을 해온 후에 배우는 교훈이다 (p.68). Quick and dirty라는 것이 없다 (p.68). 어떤 dirty한 것이 slow하다 (p.68).

빠르게 가는 유일한 방법은 well하게 가는 것이다 (p.68).

따라서 우리는 그 quality knob을 11로 turn할 것이다 (p.68-69). 만약 우리가 schedule을 shorten하고 싶다면, 유일한 옵션은 quality를 증가시키는 것이다 (p.69).

### Scope 조정

이것은 변경할 마지막 것을 남긴다 (p.69). 어쩌면, just 어쩌면, 계획된 기능 중 일부는 11월 1일까지 실제로 완료될 필요가 없을 수도 있다 (p.69). Stakeholders에게 물어보자 (p.69).

"Stakeholders, 이 모든 기능이 필요하면 3월이 될 것이다. 당신이 11월까지 절대적으로 무언가를 가져야 한다면, 당신은 일부 기능을 빼야 할 것이다." (p.69)

"우리는 무언가를 빼지 않을 것이다; 우리는 모든 것을 가져야 한다! 그리고 우리는 모든 것을 11월 1일까지 가져야 한다!" (p.69)

"아, 당신은 이해하지 못한다. 당신이 모든 것을 필요로 한다면, 우리가 그것을 하는 데는 3월까지 걸릴 것이다." (p.69)

"우리는 모든 것이 필요하고, 우리는 모든 것이 11월에 필요하다!" (p.69)

이 작은 argument는 계속 진행될 것인데, 아무도 ground를 주고 싶지 않기 때문이다 (p.69). 하지만 stakeholders가 이 argument에서 moral high ground를 가지고 있지만, programmers는 데이터를 가지고 있다 (p.69). 그리고 어떤 rational organization에서도, 데이터가 이길 것이다 (p.69).

Organization이 rational하다면, stakeholders는 결국 그들의 머리를 숙이고 수용하며 계획을 자세히 살펴보기 시작할 것이다 (p.69). 하나씩, 그들은 11월까지 절대적으로 필요하지 않은 기능을 식별할 것이다 (p.69). 이것은 상처이지만, rational organization이 가진 실제 선택은 무엇인가? (p.69-70) 그리고 그래서 계획이 조정된다 (p.70). 일부 기능이 지연된다 (p.70).

### Business Value Order

물론, inevitably stakeholders는 우리가 이미 구현한 기능을 찾을 것이고 "It's a real shame you did that one, we sure don't need it"이라고 말할 것이다 (p.70).

우리는 다시 그것을 듣고 싶지 않다! (p.70) 그래서 지금부터, 각 iteration의 시작에서, 우리는 stakeholders에게 다음으로 구현할 기능들을 묻는다 (p.70). 예, 기능들 간에 dependencies가 있다 (p.70). 하지만 우리는 programmers이고, 우리는 dependencies를 다룰 수 있다 (p.70). 한 가지 또는 다른 방식으로 우리는 stakeholders가 묻는 순서대로 기능들을 구현할 것이다 (p.70).

## 화제

⭐ Agile Manifesto의 역사와 2001년 Snowbird 회의
⭐ 4가지 Agile 가치 (Individuals and interactions, Working software, Customer collaboration, Responding to change)
⭐ Waterfall의 30년 실패와 문제점
⭐ Iron Cross 원칙과 project management
⭐ Agile의 반복적 개발과 데이터 기반 관리
⭐ Circle of Life와 XP의 practices
⭐ Hope vs. Management
⭐ Velocity와 burn-down chart를 통한 schedule 재계산
Agile 이전의 역사 (50,000년부터 시작)
Scientific Management와 Pre-Agile의 충돌
Winston Royce의 Waterfall 다이어그램
Structured Programming, Analysis, Design의 3단계 패턴
Kent Beck과 Extreme Programming (XP)
XP Immersion 부트캠프
Martin Fowler와의 협력
Alistair Cockburn과 Snowbird 회의 장소 선정
17명의 참석자들과 그들의 배경
Agile Manifesto의 창출 과정
Affinity grouping과 whiteboard moment
Manifesto preamble 작성
"Agile"이라는 이름의 선택
agilemanifesto.org 웹사이트
Principles document 작성
The Meeting: Waterfall project의 전형적 시작
Analysis Phase의 honeymoon phase
Design Phase의 문제점
Implementation Phase의 현실
Death March Phase와 project 실패
Runaway Process Inflation
The First Thing You Know: frozen date vs. fluid requirements
Date negotiation의 어려움
Analysis phase 예상과 reality의 gap
Iteration Zero와 stories
Continuous Exploration
Feedback-driven 접근
Business-facing practices (Planning Game, Small Releases, Acceptance Tests, Whole Team)
Team-facing practices (Sustainable Pace, Collective Ownership, Continuous Integration, Metaphor)
Technical practices (Pairing, Simple Design, Refactoring, Test Driven Development)
Agile Manifesto와 practices의 연결
Project를 해결하기 위한 4가지 선택 (Schedule, Staff, Quality, Scope)
New staff 추가의 부작용과 Brooks' Law
Quality와 속도의 관계
Scope 조정과 rational organization
Cost of change와 software development의 characteristics
