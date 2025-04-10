import Foundation

enum Result<Success, Failure> where Failure == Error {

    associatedType Success

    case success(value: Success)
    case failure(error: Failure)
}

extension Result {
    func map<NewSuccess>(_ transform: (Success) -> NewSuccess) -> Result<NewSuccess, Error> {
        switch self {
            case .success(let value):
                return .success(transform(value))
            case .failure:
                return self
        }
    }

    func flatMap<NewSuccess>(_ transform: (Success) -> Result<NewSuccess, Error>) -> Result<NewSuccess, Error> {
        switch self {
            case .success(let value):
                return transform(value)
            case .failure:
                return self
        }
    }
}

extension Result {
    func mapError<NewFailure>(_ transform: (Failure) -> NewFailure) -> Result<Success, NewFailure> {
        switch self {
            case .success(let value):
                return self
            case .failure(let error):
                return .failure(transform(error))
        }
    }

    func flatMapError<NewFailure>(_ transform: (Failure) -> Result<Success NewFailure>) -> Result<Success, NewFailure> {
        switch self {
            case .success(let value):
                return self
            case .failure(let error):
                return transform(error)
        }
    }
}
