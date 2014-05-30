# Error Handler

Handle NSErrors in easy way.
This class defines rules of handling and presenting NSErrors.

# Examples

Set defult title and button title:

    ErrorHandler *handler = [ErrorHandler sharedHandlerWithProperties:@{kErrorHandlingPropertyDefaultTitle : NSLocalizedString(@"Error", nil),
                                                                        kErrorHandlingPropertyDefaultCancelButtonTitle : NSLocalizedString(@"OK", nil),
                                                                        kErrorHandlingPropertyDefaultImportance : @(CapturedErrorImportanceMedium),
                                                                        kErrorHandlingPropertyEnableDebugLogs : @(YES)}];


Allow to present errors of importance greater than low, disallow to display errors of low importance:

    ErrorPresentingRule *allowGreaterThatLowImportanceRule = [ErrorPresentingRule ruleForCapturedErrorProperty:@"importance"
                                                                                                      relation:ErrorPresentingRelationGreaterThan
                                                                                                         value:@(CapturedErrorImportanceLow)
                                                                                                withPermission:ErrorPresentingPermissionAllow];
    [handler.presentingRules addObject:allowGreaterThatLowImportanceRule];
    ErrorPresentingRule *denyLowImportanceRule = [ErrorPresentingRule ruleForCapturedErrorProperty:@"importance"
                                                                                          relation:ErrorPresentingRelationIsEqual
                                                                                             value:@(CapturedErrorImportanceLow)
                                                                                    withPermission:ErrorPresentingPermissionDeny];


Set HTTP loading erros to be of low importance:

    rule = [ErrorProcessingRule ruleForDomain:NSURLErrorDomain
                                        codes:@[@(NSURLErrorTimedOut), @(NSURLErrorCannotFindHost), @(NSURLErrorNetworkConnectionLost), @(NSURLErrorNotConnectedToInternet)]
                              evaluationRules:@{kErrorProcessingEvaluationRuleImportance:@(CapturedErrorImportanceLow)}];
    [handler.processingRules addObject:rule];


When certain error appears for 3 times, do some action:

    NSMutableArray *constraints = [NSMutableArray array];
    [constraints addObject:[ErrorPostprocessingConstraint constraintWithProperty:@"domain" relation:ErrorPostprocessingRelationIsEqual value:kWebsocketsNotSupportedDomain]];
    [constraints addObject:[ErrorPostprocessingConstraint constraintWithProperty:@"code" relation:ErrorPostprocessingRelationIsEqual value:@(kWebsocketsNotSupportedCode)]];
    [constraints addObject:[ErrorPostprocessingConstraint constraintWithProperty:@"numberOfOccurences" relation:ErrorPostprocessingRelationIsEqual value:@(3)]];
    ErrorPostprocessingRule *postRule = [ErrorPostprocessingRule ruleThatSatisfiesConstraints:constraints execution:^{
        // Do some action
    }];
    [handler.postprocessingRules addObject:postRule];
