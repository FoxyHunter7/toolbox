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
    - [Chain Of Responibility (Optional)](#chain-of-responibility-optional)

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
    }
}
```

```ts
// RepositoryFactory.ts --Example 1--

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

TODO: add code examples.

### services/

Service classes contain the business logic and interact with repositories to retrieve or manipulate data. The creation of these services are done using the ServiceFactory, under no circomstances should you start manually creating instances of these.

TODO: add code examples.

### types/

This is where all typescript type declarations should be placed, along with enums in, for example; a subfolder "enums". Although the exact organisation of this folder depends on personal preference and project.

### util/

[`🔗 Wikipedia: "Facade Pattern"`](https://en.wikipedia.org/wiki/Facade_pattern)

This is the place to put all utility funtcions, functions that can be re-used cross components/files. This to avoid code duplication or to abstract away more complex functionality, see the facade design pattern.

## Design Patterns

Below you can find an overview of the design patterns which are the pillars of this architecture, and the reasoning on why and how they are implemented.

### Factory Pattern

[`🔗 Wikipedia: "Factory method pattern"`](https://en.wikipedia.org/wiki/Factory_method_pattern)

### Singleton Pattern

[`🔗 Wikipedia: "Singleton pattern"`](https://en.wikipedia.org/wiki/Singleton_pattern)

### Dependency Injection

[`🔗 Wikipedia: "Dependency injection"`](https://en.wikipedia.org/wiki/Dependency_injection)

### Lazy Initialization

[`🔗 Wikipedia: "Lazy initialization"`](https://en.wikipedia.org/wiki/Lazy_initialization)

### Chain Of Responibility (Optional)

[`🔗 Wikipedia: `]()
