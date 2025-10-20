# Contrato de Repositorio de Datos de Usuario FAIR DAO

[Inglés](README.md)  ·  [Chino(Simplificado)](README_CN.md)  ·  [Ruso](README_RU.md)  ·  [Español](README_ES.md)  ·  [Français](README_FR.md)  ·  [العربية](README_AR.md)

## Introducción
El Contrato de Repositorio de Datos de Usuario es el servicio principal de almacenamiento de datos backend de FAIR DAO para otros contratos inteligentes. Proporciona capacidades de almacenamiento de datos seguras y flexibles con mecanismos integrales de control de acceso.

## Características principales

### 1. Gestión de administradores
- **Agregar/Eliminar Administradores**: Los propietarios pueden agregar o eliminar administradores con permisos configurables
- **Control de acceso basado en roles**: Distingue entre administradores regulares y propietarios con privilegios elevados

### 2. Gestión de claves
- **Asignación de administradores de claves**: Asignar administradores específicos para controlar el acceso a claves particulares
- **Configuración por lotes de administradores de claves**: Establecer administradores para múltiples claves simultáneamente de manera eficiente
- **Seguimiento de claves**: Mantener un índice de todas las claves registradas

### 3. Funciones de almacenamiento de datos
- **Almacenamiento de datos específicos del usuario**: Almacenar y recuperar datos asociados con direcciones de usuario específicas
- **Almacenamiento de datos compartidos**: Almacenar y recuperar datos accesibles para múltiples contratos/usuarios
- **Seguimiento de marcas de tiempo**: Registrar automáticamente marcas de tiempo para todas las modificaciones de datos

### 4. Mecanismos de seguridad
- **Parada de emergencia**: Pausar operaciones críticas del contrato en caso de incidentes de seguridad
- **Validación de permisos**: Control estricto de acceso para todas las operaciones sensibles

### 5. Funciones de consulta
- **Información del administrador**: Recuperar listas de administradores y sus permisos
- **Información de claves**: Acceder a claves registradas y sus administradores asignados
- **Estado del contrato**: Comprobar si el contrato está en modo de parada de emergencia

## Funciones del contrato

### Gestión de administradores
- `addManager(address manager, bool withOwnerPermission)`: Agregar un nuevo administrador con permisos opcionales de propietario
- `removeManager(uint256 index, address manager)`: Eliminar un administrador existente
- `isManager(address user)`: Comprobar si una dirección es un administrador
- `getOwnerCount()`: Obtener el número de propietarios
- `getManagerCount()`: Obtener el número total de administradores

### Gestión de claves
- `setKeyManagers(bytes32[] keys, address oldManager, address manager)`: Establecer administradores para múltiples claves
- `isKeyManager(bytes32 key, address user)`: Comprobar si una dirección es un administrador para una clave específica
- `getKeyAtIndex(uint256 index)`: Obtener una clave en un índice específico

### Operaciones de datos
- `setUserData(address targetUser, bytes32 key, bytes data)`: Almacenar datos para un usuario específico
- `getUserData(address targetUser, bytes32 key)`: Recuperar datos específicos del usuario
- `setSharedData(bytes32 key, bytes32 sharedValueId, bytes data)`: Almacenar datos compartidos
- `getSharedData(bytes32 key, bytes32 sharedValueId)`: Recuperar datos compartidos

### Funciones de seguridad
- `enableEmergencyStop()`: Pausar operaciones críticas del contrato
- `disableEmergencyStop()`: Reanudar operaciones del contrato
- `isEmergencyStopped()`: Comprobar si el contrato está en modo de parada de emergencia

## Contribución

* Damos la bienvenida a las presentaciones de PR o informes de problemas, consulte las [Directrices de Contribución](https://github.com/fair-dao/.github/blob/main/CONTRIBUTING_ES.md).
* **Al contribuir, puede dejar su dirección de billetera TRON (al menos una vez), y evaluaremos su nivel de contribución cada trimestre y distribuiremos tokens Fair como recompensa a los participantes activos.**

## Licencia

* Derechos de autor (c) 2025 FAIR DAO. Todos los derechos reservados.
* Licenciado bajo la Licencia Pública General GNU Versión 3 ( [GPLv3](LICENSE) ).