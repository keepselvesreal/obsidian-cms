---
version: "1"
note: "초기 작성"
creator: "Claude Haiku 4.5"
created_time: "25-12-14 15:34"
---

## 압축 내용

Coupling은 시스템의 구성 요소들을 연결하는 필수적인 설계 도구이며, shared lifecycle과 shared knowledge라는 두 가지 주요 요인에 의해 그 강도가 결정되고, 시스템이 목적을 달성하기 위해서는 적절한 coupling이 반드시 필요하다.

## 핵심 내용

### Coupling의 정의

Coupling은 "함께 연결하다(fasten together)"를 의미하는 라틴어 "copulare"에서 유래했으며, 두 개 이상의 엔티티가 연결되어 서로 영향을 미칠 수 있는 관계를 나타낸다. "Coupled"는 "connected"와 동의어로 사용될 수 있다.

### Magnitude of Coupling

Coupling의 강도는 연결된 컴포넌트들의 상호의존성을 반영하며, 두 가지 주요 요인에 의해 결정된다: (1) Shared Lifecycle - 같은 encapsulation boundary 내에 위치한 컴포넌트들은 함께 테스트되고 배포되어야 하므로 lifecycle coupling이 높다. (2) Shared Knowledge - 컴포넌트들이 공유하는 지식(integration interface, 기능 요구사항, 구현 세부사항 등)이 많을수록 더 많은 cascading changes가 발생한다.

### Flow of Knowledge

Knowledge는 dependency의 반대 방향으로 흐른다. Upstream 컴포넌트는 다른 컴포넌트들이 소비하는 기능을 제공하며 그 지식을 integration interface를 통해 노출하고, downstream 컴포넌트는 upstream 컴포넌트의 기능을 사용하기 위해 해당 지식을 알아야 한다.

### Systems와 Coupling

시스템은 목적을 달성하기 위해 조직화된 상호 연결된 요소들의 집합이며, components, interconnections, purpose라는 세 가지 핵심 요소로 구성된다. Coupling은 시스템을 하나로 묶는 접착제이며, coupling 없이는 시스템이 목적을 달성할 수 없다.

## 상세 내용

- [[#Coupling의 어원과 보편성]]
- [[#Magnitude of Coupling: 상호의존성의 척도]]
- [[#Shared Lifecycle]]
- [[#Shared Knowledge]]
- [[#Implicit Shared Knowledge]]
- [[#Flow of Knowledge: Upstream과 Downstream]]
- [[#Systems의 정의]]
- [[#소프트웨어 시스템의 계층적 특성]]
- [[#Coupling in Systems: 시스템을 구성하는 필수 요소]]
- [[#시스템의 세 요소 간 상호관계]]
- [[#Boundaries의 중요성]]
- [[#Essential vs Accidental Coupling]]
- [[#기계공학에서의 Coupling과 Tolerances]]

### Coupling의 어원과 보편성

"Coupling"은 라틴어 "copulare"에서 유래했으며, "co(함께)"와 "apere(연결하다)"의 합성어다. 따라서 "to couple"은 "함께 연결하다" 또는 단순히 "연결하다"를 의미한다. Coupling은 어디서나 관찰할 수 있는 보편적 현상이다: 시계의 톱니바퀴들, 차량의 엔진과 바퀴들, 살아있는 유기체의 장기들, 우주의 입자들, 중력으로 연결된 천체들 등 모든 연결된 엔티티는 coupled 되어 있다.

### Magnitude of Coupling: 상호의존성의 척도

Coupling의 magnitude는 연결된 컴포넌트들의 상호의존성을 반영한다. 연결이 강할수록 시간이 지남에 따라 관계를 유지하는 데 더 많은 노력이 필요하다. "느슨하게 연결된(loosely coupled)" 컴포넌트들도 여전히 연결되어 있으므로 완전히 독립적일 수는 없다. 소프트웨어 설계에서 coupling의 magnitude가 높을수록 coupled된 컴포넌트들이 함께 변경되어야 하는 빈도가 높아진다.

### Shared Lifecycle

여러 컴포넌트가 함께 변경되어야 하는 가장 직접적인 이유는 lifecycle의 coupling이다. 예를 들어, 같은 monolithic 시스템에 공존하는 Payments와 Authorization 모듈은 함께 테스트되고 배포되어야 하므로 높은 lifecycle coupling을 가진다. 반면, 이들을 각각 Billing과 Identity & Access라는 별도의 서비스로 추출하면 lifecycle coupling이 감소하여 각각 더 독립적으로 개발하고 유지보수할 수 있다 (pp. 58-60).

### Shared Knowledge

함께 작동하기 위해 coupled된 컴포넌트들은 지식을 공유해야 한다. 공유되는 지식은 다양한 형태를 가질 수 있다: integration interface에 대한 인식, 기능 요구사항, 해당 모듈의 구현 세부사항 등. 공유된 지식의 일부가 변경되면 연결된 모듈에도 해당 변경이 적용되어야 한다. 컴포넌트 경계를 넘어 공유하는 지식이 많을수록 더 많은 cascading changes가 발생한다.

예를 들어, CustomersService 모듈과 repository 객체의 세 가지 대안적 설계를 비교하면 (pp. 61-63):
- MySQLRepository: MySQL이라는 구체적인 데이터베이스를 공유 - 가장 많은 지식 공유
- IRepository with BeginTransaction/ExecuteSQL: 관계형 데이터베이스 계열이라는 지식 공유 - 중간 수준의 지식 공유
- IRepository with Save/Query: 최소한의 추상적 지식만 공유 - 가장 적은 지식 공유

### Implicit Shared Knowledge

공유되는 지식은 암묵적일 수도 있다. 컴포넌트들은 명시적으로 정의되거나 공유되지 않은 지식에 대해서도 암묵적 가정을 할 수 있다. 예를 들어, 시스템이 특정 버전의 운영체제나 특정 하드웨어에서 실행된다고 가정하는 경우다 (p. 64).

### Flow of Knowledge: Upstream과 Downstream

지식의 흐름은 dependency의 반대 방향으로 발생한다. Distribution 컴포넌트가 CRM 컴포넌트를 참조하고 의존한다면, Distribution은 CRM의 integration interface, 기능, 운영 세부사항을 알아야 한다. 이 모든 지식은 CRM 모듈이 integration interface를 통해 공유하며, 결과적으로 지식의 흐름은 dependency의 반대 방향으로 발생한다 (pp. 64-66).

용어 정의:
- **Upstream 컴포넌트**: 다른 컴포넌트들이 소비하는 기능을 제공한다. 그 interface는 기능과 통합 방법에 대한 지식을 노출한다.
- **Downstream 컴포넌트**: upstream 컴포넌트의 기능을 소비한다. upstream 컴포넌트를 사용하기 위해 integration interface를 통해 공유되는 지식을 알아야 한다.

### Systems의 정의

Donella H. Meadows는 시스템을 "무언가를 달성하기 위해 조직화된 상호 연결된 요소들의 집합"으로 정의한다. 이 간결한 정의는 모든 시스템을 구성하는 세 가지 핵심 요소를 설명한다: **components**(구성 요소), **interconnections**(상호 연결), **purpose**(목적) (p. 66).

### 소프트웨어 시스템의 계층적 특성

소프트웨어 자체는 상호 연결된 시스템들의 시스템으로 이해할 수 있다. 더 높은 수준에서는 서비스, 애플리케이션, 스케줄된 작업, 데이터베이스 등이 결합되어 시스템의 비즈니스 기능을 수행한다. 그러나 이러한 대규모 컴포넌트들도 더 낮은 수준에서는 그 자체로 시스템이다. 예를 들어:
- 서비스는 클래스들로 구성된 시스템
- 클래스는 메서드와 변수들로 구성된 시스템
- 메서드는 명령문들로 구성된 시스템

이러한 계층적 구조는 Chapter 12 "Fractal Geometry of Software Design"에서 더 자세히 다루어진다 (pp. 66-68).

### Coupling in Systems: 시스템을 구성하는 필수 요소

시계의 톱니바퀴들은 clockwork 시스템의 컴포넌트다. Clockwork 시스템의 목적은 시간을 측정하고 표시하는 것이다. 그러나 필요한 톱니바퀴와 스프링을 가지고 있는 것만으로는 목적을 달성하기에 충분하지 않다. 시스템이 유용하려면 컴포넌트들이 함께 작동할 수 있도록 연결되어야(coupled) 한다. 컴포넌트들은 시스템의 목표를 달성하는 방식으로 coupled되어야 한다. **Coupling은 시스템을 하나로 묶는 접착제일 뿐만 아니라, 시스템의 가치를 부분의 합보다 더 크게 만드는 요소다** (pp. 69-70).

### 시스템의 세 요소 간 상호관계

시스템을 구성하는 세 가지 요소—components, interactions, purpose—는 강하게 상호 연관되어 있다 (pp. 70-72):
- 시스템의 목적은 특정 컴포넌트 집합과 그들 간의 상호작용을 요구한다.
- 컴포넌트 인터페이스의 설계는 특정 통합을 허용하고 다른 것들을 금지한다. 또한 컴포넌트의 기능이 시스템이 목적을 달성할 수 있게 한다.
- 상호작용은 컴포넌트의 작업을 조율하여 시스템이 목적을 달성할 수 있게 한다.

전체적으로, 주어진 시스템에서 세 가지 요소 중 어느 하나도 나머지 두 개 중 적어도 하나에 영향을 주지 않고는 변경할 수 없다.

### Boundaries의 중요성

Ruth Malan의 말처럼, "시스템 설계는 본질적으로 경계(무엇이 안에 있고, 무엇이 밖에 있고, 무엇이 걸쳐 있고, 무엇이 사이를 이동하는가)와 트레이드오프에 관한 것이다." 컴포넌트의 경계는 어떤 지식이 컴포넌트에 속하고 무엇이 외부에 남아야 하는지를 정의한다. 예를 들어:
- 어떤 기능이 컴포넌트에 의해 구현되어야 하는가
- 어떤 책임이 시스템의 다른 부분에 할당되어야 하는가
- 어떤 지식이 경계를 통과할 수 있는가

궁극적으로 컴포넌트와 상호작용은 시스템 설계로 달성할 수 있는 결과를 정의한다. 이는 상호작용—컴포넌트가 coupled되는 방식의 설계—를 시스템 설계의 본질적인 부분으로 만든다 (p. 72).

### Essential vs Accidental Coupling

Coupling이 시스템을 함께 묶는 접착제라는 것이 관계와 상호의존성을 맹목적으로 도입하면 좋은 설계가 된다는 의미는 아니다. Coupling은 essential(본질적)이거나 accidental(우발적)일 수 있다. 모듈러 설계는 accidental coupling을 제거하면서 essential한 상호관계를 신중하게 관리해야 한다 (p. 74).

### 기계공학에서의 Coupling과 Tolerances

기계공학에서 coupling은 제조 과정의 불가피한 불완전성을 고려하여 비용을 절감하는 설계 도구로 사용된다. 두 부품의 연결점(coupling joints)이 정확히 동일하게 설계되면 제조 불완전성으로 인한 낭비가 발생할 수 있다. 이를 해결하기 위해 컴포넌트의 연결점은 tolerances(허용 오차)와 함께 설계된다: 물리적 치수나 재료 특성의 허용 가능한 변동 한계. 이러한 tolerances는 일정량의 여유를 허용하여 신뢰할 수 있는 연결을 가능하게 하면서도 제조 낭비와 생산 비용을 최소화한다. Tolerances는 신중하게 설계되어야 한다 - 너무 높으면 신뢰할 수 없는 연결이 되고, 너무 낮으면 가능한 모든 제조 불완전성을 해결하지 못한다 (pp. 74-76).

## 화제

- ⭐ Coupling의 정의와 어원 (copulare: to fasten together)
- ⭐ Coupling의 보편성 (시계, 차량, 유기체, 입자, 천체)
- ⭐ Magnitude of Coupling과 상호의존성
- ⭐ Shared Lifecycle (encapsulation boundaries, 테스트/배포)
- ⭐ Shared Knowledge (integration interface, 기능, 구현 세부사항)
- CustomersService와 Repository의 세 가지 설계 대안 비교
- ⭐ Implicit Shared Knowledge와 암묵적 가정
- ⭐ Flow of Knowledge (upstream/downstream)
- Upstream 컴포넌트 (기능 제공자)
- Downstream 컴포넌트 (기능 소비자)
- ⭐ 시스템의 정의 (Donella H. Meadows)
- ⭐ 시스템의 세 가지 핵심 요소 (components, interconnections, purpose)
- 소프트웨어 시스템의 계층적 특성 (서비스 → 클래스 → 메서드 → 명령문)
- ⭐ Coupling은 시스템을 묶는 접착제
- Clockwork 시스템 예시
- 시스템의 세 요소 간 상호의존성
- Boundaries의 중요성 (Ruth Malan의 인용)
- 컴포넌트 경계와 지식의 범위
- ⭐ 상호작용(coupling)은 시스템 설계의 본질적 부분
- Coupling을 zero로 줄이는 것은 불가능
- 상호작용은 지식 공유를 요구함
- 소프트웨어 엔지니어의 초점: 박스(컴포넌트)뿐만 아니라 선(상호작용)도 중요
- ⭐ Essential Coupling vs Accidental Coupling
- 기계공학에서의 Coupling 활용
- Tolerances (허용 오차)와 제조 비용 관리
- Coupling은 나쁜 설계의 동의어가 아닌 설계 도구
