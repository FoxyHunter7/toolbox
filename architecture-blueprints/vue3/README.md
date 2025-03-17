# FoxyHunter's VUE3 Architecture Blueprint

This architecture is what I've found works best for me personally; by no means should it be seen as "the solution" or "the best way."

It is designed to scale, stay maintainable, and support testing by clearly separating responsibilities. Data management *(repositories)* is distinct from business logic *(services)*, with factories handling the creation and management of these components. The result is a flexible, modular structure that simplifies updates, testing, and scaling, all while maintaining core functionality.

> **WARNING:** This architecture is best suited for larger, more complex Vue projects. For smaller projects, the added structure may introduce unnecessary complexity.

- [FoxyHunter's VUE3 Architecture Blueprint](#foxyhunters-vue3-architecture-blueprint)
  - [Best Practices](#best-practices)
    - [Typscript](#typscript)
    - [Composition API](#composition-api)
    - [Seperation Of Concerns](#seperation-of-concerns)
  - [File Structure](#file-structure)
    - [data/](#data)
    - [factories/](#factories)
    - [repositories/](#repositories)
    - [services/](#services)
    - [types/](#types)
    - [util/](#util)
  - [Design Patterns](#design-patterns)
    - [Factory Pattern](#factory-pattern)
    - [Singleton Pattern](#singleton-pattern)
    - [Dependency Injection](#dependency-injection)
    - [Lazy Initialization](#lazy-initialization)
  - [Additional Considerations](#additional-considerations)

## Best Practices

### Typscript

[`🔗 Official VUE Docs: "Using Vue with TypeScript"`](https://vuejs.org/guide/typescript/overview)

For larger projects, it's always recommended to use type-safe languages. While they can be frustrating at times, you'll be thankful when they help you avoid mistakes or overlook issues. Install the proper TypeScript linters and avoid bad practices, such as using "any" whenever possible.

### Composition API

[`🔗 Official VUE Docs: "Composition API FAQ -> Why Composition API?"`](https://vuejs.org/guide/extras/composition-api-faq.html#why-composition-api)

The composition API is more efficient, allows for cleaner code with better reuse of functions and logic, it also provides more flexibility in how you structure your code.

It better groups related code blocks together and works best with Type Inference when using TypeScript.

### Seperation Of Concerns

[`🔗 Wikipedia: "Module Pattern"`](https://en.wikipedia.org/wiki/Module_pattern)

Ensuring that each "module", component, or part of code is solely responsible for completing its specific task greatly improves simplicity and readability.

## File Structure

Below is an overview of the desired file/folder structure within the `src/` folder of your VUE project.

- assets/   - *Stores static assets like CSS files, media, ...*
- components/   - *Vue components, organised as seen fit in the context of the project.*
- **(new) data/**
- **(new) factories/**
- **(new) repositories/**
- router/   - *Vue Router*
- **(new) services/**
- **(new) types/**
- **(new) util/**
- views/    - *The main views of your application.*

### data/

Contains configuration files that may read ".env" values and ensure defaults.

For example:

```ts
const env = {
  "APIFQDN": import.meta.env.VITE_API_FQDN,
  "APIPort": import.meta.env.VITE_API_PORT,
  "APISecure": import.meta.env.VITE_API_SECURE,
}

const config = {
  "REST_URL": `${env.APISecure === "true" ? "https" : "http"}://${env.APIFQDN}:${env.APIPort}/`,
  "SOCKET_URL": `${env.APISecure === "true"? "wss" : "ws"}://${env.APIFQDN}:${env.APIPort}/`,
}

export default config;
```

### factories/

Factory classes manage the creation of services and repositories. The `ServiceFactory` is responsible for deciding which repository to inject into the service instance before returning it. The `ServiceFactory` gets it's repository instance from the `RepositoryFactory`, which has a method per repository *(eg. getEventRepository)*, which take as argument the implementation of that repository that you want.

```ts
// ServiceFactory.ts --Example 1--

import { EventService } from '@/services/EventService';
import { RepositoryFactory } from '@/factories/RepositoryFactory';
import { EventRepositoryImplementations } from '@/types/enums/repositories/EventRepositryImplementations'

export class ServiceFactory {
  private static eventService: EventService;

  // Singleton pattern to ensure there's only one instance of EventService
  public static getEventService(): EventService {
    if (!this.eventService) {
      this.eventService = new EventService(
        // Get the repository based on a predefined choice (e.g., API)
        RepositoryFactory.getEventRepository(EventRepositoryImplementations.API)
      );
    }
    return this.eventService;
  }
}
```

```ts
// ServiceFactory.ts --Example 2--

import { EventService } from '@/services/EventService';
import { RepositoryFactory } from '@/factories/RepositoryFactory';
import { EventRepositoryImplementations } from '@/types/enums/repositories/EventRepositryImplementations';

export class ServiceFactory {
  private static eventService: EventService;

  // Singleton pattern to ensure there's only one instance of EventService
  public static getEventService(): EventService {
    if (!this.eventService) {
      this.eventService = new EventService(
        // Dynamically decide which repository to use based on some logic
        RepositoryFactory.getEventRepository(getEventRepositoryImplementation())
      );
    }
    return this.eventService;
  }

  private static getEventRepositoryImplementation(): EventRepositoryImplementations {
    // logic to determine which repo implementation to use.
    // Advised to mind the chain of responsibility pattern should this logic rely on something repo specific.
  }
}
```

```ts
// RepositoryFactory.ts --Example--

import { IEventRepository } from '@/repositories/IEventRepository';
import { APIEventRepository } from '@/repositories/event-repositories/APIEventRepository';
import { JSONEventRepository } from '@/repositories/event-repositories/JSONEventRepository';
import { EventRepositoryImplementations } from '@/types/enums/repositories/EventRepositryImplementations';

export class RepositoryFactory {
  // Map to store already instantiated repositories (enforces Singleton pattern).
  private static eventRepositories = new Map<EventRepositoryImplementations, IEventRepository>();

  // Map to link repository implementations to their respective classes.
  // The key is the enum value, and the value is the class constructor.
  private static eventRepositoriesClassMap = {
    [EventRepositoryImplementations.API]: APIEventRepository,
    [EventRepositoryImplementations.JSON]: JSONEventRepository
  };

  /**
   * Returns an instance of the requested event repository.
   * If the repository has already been instantiated, it retrieves the existing instance.
   * Otherwise, it creates a new instance, stores it, and then returns it.
   * 
   * @param implementation - The type of repository to instantiate, specified by the enum.
   * @returns An instance of the requested repository.
   * @throws If the specified repository implementation is not found.
   */
  public static getEventRepository(implementation: EventRepositoryImplementations): IEventRepository {
    // Check if the repository instance already exists in the map.
    if (!this.eventRepositories.has(implementation)) {
      // Retrieve the repository class constructor from the class map.
      const RepositoryClass = this.eventRepositoriesClassMap[implementation];

      // If no class is found for the requested implementation, throw an error.
      if (!RepositoryClass) {
        throw new Error(`Repository implementation: ${implementation} not found.`);
      }

      // Instantiate the repository and store it in the map.
      this.eventRepositories.set(implementation, new RepositoryClass());
    }

    // Retrieve and return the stored repository instance.
    return this.eventRepositories.get(implementation)!;
  }
}
```

### repositories/

Repositoriy classes handle data interaction, Each repository should have an interface followed by each implementation of that interface.

```ts
// EventRepository.ts --Example--

import type { event } from '@/types/event';

export interface IEventRepository {
  getEvents(): Promise<event[]>;
  saveEvent(event: event): Promise<void>;
}
```

```ts
// APIEventRepository.ts --example--

import { IEventRepository } from '@/repositories/IEventRepository';
import type { event } from '@/types/event';

export class APIEventRepository implements IEventRepository {
  async getEvents(): Promise<event[]> {
    // Fetch events from an API endpoint
    const response = await fetch('https://api.example.com/events');
    return response.json();
  }

  async saveEvent(event: event): Promise<void> {
    // Save event via the API
    await fetch('https://api.example.com/events', {
      method: 'POST',
      body: JSON.stringify(event),
    });
  }
}
```

```ts
// JSONEventRepository.ts --example--

import { IEventRepository } from '@/repositories/IEventRepository';
import type { event } from '@/types/event';

export class JSONEvenetRepository implements IEventRepository {
  async getEvents(): Promise<event[]> {
    // Simulate fetching events from a local JSON file
    const response = await fetch('/assets/events.json');
    return response.json();
  }

  async saveEvent(event: event): Promise<void> {
    // Simulate saving event to a local JSON file
    const events = await this.getEvents();
    events.push(event);
    await fetch('/assets/events.json', {
      method: 'POST',
      body: JSON.stringify(events),
    });
  }
}
```

### services/

Service classes contain the business logic and interact with repositories to retrieve or manipulate data. The creation of these services are done using the ServiceFactory, under no circomstances should you start manually creating instances of these.

```ts
// EventService.ts --example--

import { IEventRepository } from '@/repositories/IEventRepository';

export class EventService {
  private repository: IEventRepository;

  constructor(repository: IEventRepository) {
    this.repository = repository;
  }

  async getEventList() {
    const events = await this.repository.getEvents();
    // Process events (e.g., sort, filter)
    return events;
  }

  async createEvent(event: any) {
    await this.repository.saveEvent(event);
    // Add further logic for event creation if necessary
  }
}
```

### types/

This is where all typescript type declarations should be placed, along with enums in, for example; a subfolder "enums". Although the exact organisation of this folder depends on personal preference and project.

### util/

[`🔗 Wikipedia: "Facade Pattern"`](https://en.wikipedia.org/wiki/Facade_pattern)

This is the place to put all utility funtcions, functions that can be re-used cross components/files. This to avoid code duplication or to abstract away more complex functionality, see the facade design pattern.

## Design Patterns

Below you can find an overview of the design patterns which are the pillars of this architecture, and the reasoning on why and how they are implemented.

### Factory Pattern

[`🔗 Wikipedia: "Factory method pattern"`](https://en.wikipedia.org/wiki/Factory_method_pattern)

The **Factory Pattern** provides a way to create objects without specifying the exact class of object that will be created. In this architecture:

- The `RepositoryFactory` is responsible for creating repository instances.
- The `ServiceFactory` handles the creation of services, deciding which repository to inject into the service's constructor.

This pattern keeps object creation separate and makes it easy to switch or add new implementations without changing the rest of the code.

**Advantages:**

- Simplifies how objects are created.
- Makes the code flexible and easy to extend.
- Follow the Open-closed Principle, meaning the code can be extended without chaning existing code.
  - [`🔗 Wikipedia: "Open-closed principle"`](https://en.wikipedia.org/wiki/Open%E2%80%93closed_principle)

### Singleton Pattern

[`🔗 Wikipedia: "Singleton pattern"`](https://en.wikipedia.org/wiki/Singleton_pattern)

The Singleton Pattern ensures that only one instance of a class exists. In this architecture:

- `ServiceFactory` and `RepositoryFactory` make sure there is only one instance of each service and repository.
- For example, `ServiceFactory` always returns the same EventService instance.

**Advantages:**

- Reduce memory usage by reusing the same instance.
- Prevents problems caused by having multiple instances, such as inconsistent data.

### Dependency Injection

[`🔗 Wikipedia: "Dependency injection"`](https://en.wikipedia.org/wiki/Dependency_injection)

**Dependency Injection** is a way to give a class the dependencies it needs instead of that class creating them. In this architecture:

- `ServiceFactory` provides the required repository to the service when it's created.
- This makes it easy to change wich repository is used without modifying the service.

**Advantages:**

- Real dependencies can be replaced by fake ones, in testing.
- Increases flexibility, as we can swap out dependencies without changing the code that uses them.
- Helps follow the Dependency Inversion Principle, where high-level code doesn't depend on low-level code.
  - [`🔗 Wikipedia: "Dependency inversion principle"`](https://en.wikipedia.org/wiki/Dependency_inversion_principle)

### Lazy Initialization

**Lazy Initialization** delays the creation of an object until it is needed, which helps optimise performance and resource usage. In this architecture:

- `RepositoryFactory` and `ServiceFactory` only create objects when their methods are called, saving resources.
- repositories & services are stored, only created when request for the first time.

**Advantages:**

- Saves memory by not creating unused objects.
- Improved startup time.

[`🔗 Wikipedia: "Lazy initialization"`](https://en.wikipedia.org/wiki/Lazy_initialization)

## Additional Considerations

Theoretically, in a project with many complex repositories, lazy loading of repository imports in the RepositoryFactory could improve performance. However, this approach would significantly increase cognitive complexity, so it has been deliberately avoided in this architecture to maintain clarity and simplicity.
