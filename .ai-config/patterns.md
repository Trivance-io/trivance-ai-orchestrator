# 🎨 Patrones de Código - Trivance Platform

## 🔧 Patrones de Componentes React (Frontend)

### Estructura Estándar de Componente
```typescript
// Archivo: src/components/ComponentName/ComponentName.tsx
interface ComponentNameProps {
  id?: string;
  className?: string;
  children?: React.ReactNode;
  // Props específicas del componente
}

export const ComponentName: React.FC<ComponentNameProps> = ({ 
  id, 
  className, 
  children,
  ...props 
}) => {
  // Hooks locales
  const [state, setState] = useState<Type>(initialValue);
  
  // Custom hooks
  const { data, loading, error } = useComponentLogic();
  
  // Handlers
  const handleAction = useCallback(() => {
    // Lógica del handler
  }, [dependencies]);
  
  // Early returns
  if (loading) return <Spinner />;
  if (error) return <ErrorMessage error={error} />;
  
  return (
    <div id={id} className={clsx("component-base-class", className)}>
      {children}
    </div>
  );
};
```

### Lógica Separada (ComponentLogic.ts)
```typescript
// Archivo: src/components/ComponentName/ComponentNameLogic.ts
import { useState, useEffect, useCallback } from 'react';

export const useComponentLogic = () => {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  
  // Lógica del componente
  
  return { data, loading, error };
};
```

## 🏗️ Patrones de Módulos NestJS (Backend)

### Estructura Estándar de Módulo
```typescript
// Archivo: src/modules/entity/entity.module.ts
@Module({
  imports: [
    MongooseModule.forFeature([{ name: Entity.name, schema: EntitySchema }])
  ],
  controllers: [EntityController],
  providers: [EntityService],
  exports: [EntityService]
})
export class EntityModule {}
```

### Controller Pattern
```typescript
// Archivo: src/modules/entity/entity.controller.ts
@Controller('entity')
@UseGuards(JwtAuthGuard)
export class EntityController {
  constructor(private readonly entityService: EntityService) {}

  @Get()
  async findAll(@Query() query: FindAllEntityDto) {
    return this.entityService.findAll(query);
  }

  @Post()
  async create(@Body() createEntityDto: CreateEntityDto) {
    return this.entityService.create(createEntityDto);
  }

  @Get(':id')
  async findOne(@Param('id') id: string) {
    return this.entityService.findOne(id);
  }

  @Put(':id')
  async update(
    @Param('id') id: string,
    @Body() updateEntityDto: UpdateEntityDto
  ) {
    return this.entityService.update(id, updateEntityDto);
  }

  @Delete(':id')
  async remove(@Param('id') id: string) {
    return this.entityService.remove(id);
  }
}
```

### Service Pattern
```typescript
// Archivo: src/modules/entity/entity.service.ts
@Injectable()
export class EntityService {
  constructor(
    @InjectModel(Entity.name) private entityModel: Model<EntityDocument>
  ) {}

  async findAll(query: FindAllEntityDto): Promise<Entity[]> {
    const { page = 1, limit = 10, search } = query;
    const skip = (page - 1) * limit;
    
    const filter = search ? { name: { $regex: search, $options: 'i' } } : {};
    
    return this.entityModel
      .find(filter)
      .skip(skip)
      .limit(limit)
      .exec();
  }

  async create(createEntityDto: CreateEntityDto): Promise<Entity> {
    const entity = new this.entityModel(createEntityDto);
    return entity.save();
  }

  async findOne(id: string): Promise<Entity> {
    const entity = await this.entityModel.findById(id).exec();
    if (!entity) {
      throw new NotFoundException(`Entity with id ${id} not found`);
    }
    return entity;
  }

  async update(id: string, updateEntityDto: UpdateEntityDto): Promise<Entity> {
    const entity = await this.entityModel
      .findByIdAndUpdate(id, updateEntityDto, { new: true })
      .exec();
    
    if (!entity) {
      throw new NotFoundException(`Entity with id ${id} not found`);
    }
    
    return entity;
  }

  async remove(id: string): Promise<void> {
    const result = await this.entityModel.findByIdAndDelete(id).exec();
    if (!result) {
      throw new NotFoundException(`Entity with id ${id} not found`);
    }
  }
}
```

## 📱 Patrones de Pantallas React Native (Mobile)

### Estructura Estándar de Pantalla
```typescript
// Archivo: src/pages/ScreenName/ScreenName.tsx
interface ScreenNameProps {
  navigation: NavigationProp<any>;
  route: RouteProp<any>;
}

export const ScreenName: React.FC<ScreenNameProps> = ({ navigation, route }) => {
  // Redux hooks
  const dispatch = useAppDispatch();
  const { data, loading } = useAppSelector(state => state.slice);
  
  // Local state
  const [localState, setLocalState] = useState(null);
  
  // Custom hooks
  const { handleSubmit, formState } = useScreenLogic();
  
  // Effects
  useEffect(() => {
    // Screen initialization
  }, []);
  
  // Handlers
  const handleNavigation = useCallback(() => {
    navigation.navigate('NextScreen', { param: 'value' });
  }, [navigation]);
  
  // Render loading
  if (loading) {
    return (
      <View style={styles.container}>
        <ActivityIndicator size="large" />
      </View>
    );
  }
  
  return (
    <SafeAreaView style={styles.container}>
      <ScrollView contentContainerStyle={styles.content}>
        {/* Screen content */}
      </ScrollView>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
  },
  content: {
    padding: 16,
  },
});
```

## 🎯 Patrones de DTOs

### DTO con Validación
```typescript
// Archivo: src/modules/entity/dto/create-entity.dto.ts
import { IsString, IsOptional, IsEmail, IsNotEmpty } from 'class-validator';

export class CreateEntityDto {
  @IsString()
  @IsNotEmpty()
  name: string;

  @IsEmail()
  email: string;

  @IsString()
  @IsOptional()
  description?: string;
}
```

### Update DTO
```typescript
// Archivo: src/modules/entity/dto/update-entity.dto.ts
import { PartialType } from '@nestjs/mapped-types';
import { CreateEntityDto } from './create-entity.dto';

export class UpdateEntityDto extends PartialType(CreateEntityDto) {}
```

## 🔍 Patrones de GraphQL (Management API)

### Resolver Pattern
```typescript
// Archivo: src/modules/entity/entity.resolver.ts
@Resolver(() => Entity)
export class EntityResolver {
  constructor(private readonly entityService: EntityService) {}

  @Query(() => [Entity])
  async entities(@Args() args: FindAllEntityArgs): Promise<Entity[]> {
    return this.entityService.findAll(args);
  }

  @Query(() => Entity)
  async entity(@Args('id') id: string): Promise<Entity> {
    return this.entityService.findOne(id);
  }

  @Mutation(() => Entity)
  async createEntity(@Args('input') input: CreateEntityInput): Promise<Entity> {
    return this.entityService.create(input);
  }

  @Mutation(() => Entity)
  async updateEntity(
    @Args('id') id: string,
    @Args('input') input: UpdateEntityInput
  ): Promise<Entity> {
    return this.entityService.update(id, input);
  }

  @Mutation(() => Boolean)
  async deleteEntity(@Args('id') id: string): Promise<boolean> {
    await this.entityService.remove(id);
    return true;
  }
}
```

## 🎨 Patrones de Estilos

### Tailwind CSS (Frontend)
```typescript
// Patrones de clases reutilizables
const buttonClasses = {
  base: "px-4 py-2 rounded-md font-medium transition-colors",
  primary: "bg-blue-600 text-white hover:bg-blue-700",
  secondary: "bg-gray-200 text-gray-900 hover:bg-gray-300",
  danger: "bg-red-600 text-white hover:bg-red-700"
};

// Uso
<button className={clsx(buttonClasses.base, buttonClasses.primary)}>
  Click me
</button>
```

### StyleSheet React Native (Mobile)
```typescript
// Patrones de estilos reutilizables
const commonStyles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
  },
  centerContent: {
    justifyContent: 'center',
    alignItems: 'center',
  },
  padding: {
    padding: 16,
  },
  marginBottom: {
    marginBottom: 16,
  },
});
```

## 🔒 Patrones de Autenticación

### JWT Guard Pattern
```typescript
// Archivo: src/guards/jwt-auth.guard.ts
@Injectable()
export class JwtAuthGuard extends AuthGuard('jwt') {
  canActivate(context: ExecutionContext): boolean | Promise<boolean> {
    // Custom logic here
    return super.canActivate(context);
  }

  handleRequest(err: any, user: any) {
    if (err || !user) {
      throw err || new UnauthorizedException();
    }
    return user;
  }
}
```

## 📝 Patrones de Testing

### Unit Test Pattern
```typescript
// Archivo: src/modules/entity/entity.service.spec.ts
describe('EntityService', () => {
  let service: EntityService;
  let model: Model<EntityDocument>;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        EntityService,
        {
          provide: getModelToken(Entity.name),
          useValue: {
            find: jest.fn(),
            findById: jest.fn(),
            findByIdAndUpdate: jest.fn(),
            findByIdAndDelete: jest.fn(),
            save: jest.fn(),
          },
        },
      ],
    }).compile();

    service = module.get<EntityService>(EntityService);
    model = module.get<Model<EntityDocument>>(getModelToken(Entity.name));
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('findAll', () => {
    it('should return an array of entities', async () => {
      const entities = [{ name: 'Test' }];
      jest.spyOn(model, 'find').mockReturnValue({
        skip: jest.fn().mockReturnThis(),
        limit: jest.fn().mockReturnThis(),
        exec: jest.fn().mockResolvedValue(entities),
      } as any);

      const result = await service.findAll({ page: 1, limit: 10 });
      expect(result).toEqual(entities);
    });
  });
});
```

## 🎯 Mejores Prácticas

### Nomenclatura
- **Archivos**: camelCase para TS/JS, PascalCase para componentes
- **Carpetas**: kebab-case
- **Variables**: camelCase
- **Constantes**: UPPER_SNAKE_CASE
- **Interfaces**: PascalCase con sufijo `Props`, `Dto`, `Args`

### Estructura de Commits
```bash
feat: agregar nueva funcionalidad
fix: corregir bug específico
docs: actualizar documentación
style: cambios de formato
refactor: refactorización sin cambios funcionales
test: agregar o modificar tests
chore: tareas de mantenimiento
```

### Importaciones
```typescript
// Orden de importaciones
import React from 'react';           // External libraries
import { useState } from 'react';    // External libraries (named imports)

import { Component } from '@/components';  // Internal absolute imports
import { utility } from '../utils';       // Internal relative imports

import './styles.css';                     // Styles last
```

---

**Nota**: Estos patrones son específicos para Trivance Platform. Siempre seguir estos patrones para mantener consistencia en el código.