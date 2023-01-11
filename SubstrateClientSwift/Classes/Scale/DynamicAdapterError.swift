import Foundation

enum DynamicAdapterError: Error {
    case dynamicAdapterGivenInvalidType
    case typeIsNotDynamicException
    case typeIsNotFoundInRuntimeMetadataException
    case unsupportedDynamicTypeException
    case noDataConstructorException
    case internalFailure
}
