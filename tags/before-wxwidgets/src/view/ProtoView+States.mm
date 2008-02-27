#include "ProtoView.h"

@implementation ProtoView (States)
- (void) applicationIsConfigured
{
	ceguiManager->setControlButtonText ("Start");
	ceguiManager->showControlWindow();
}

- (void) applicationIsRunning
{
	ceguiManager->setControlButtonText ("Pause");
	[applicationController startSession];
	root = [super root];
}

- (void) applicationIsPaused
{
	ceguiManager->setControlButtonText ("Resume");
}

- (void) setState: (ProtoApplicationState) newState
{
	applicationState = newState;
	switch (applicationState){
		case Configured:
			[self applicationIsConfigured];
			break;
		case Running:
			[self applicationIsRunning];
			break;
		case Paused:
			[self applicationIsPaused];
			break;
	}
}

- (ProtoApplicationState) currentState
{
	return applicationState;
}

- (void) controlButton
{
	switch (applicationState){
		case Initialized: 
			//impossible case (control window is not there)
			break;
		case Configured:
			[self setState: Running];
			break;
		case Running:
			[self setState: Paused];
			break;
		case Paused:
			[self setState: Running];
			break;
	}
}

- (BOOL) isPaused
{
	if (applicationState == Paused){
		return YES;
	}else{
		return NO;
	}
}
@end
