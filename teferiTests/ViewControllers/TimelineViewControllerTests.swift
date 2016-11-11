import XCTest
import Nimble
import RxSwift
@testable import teferi

class TimelineViewControllerTests : XCTestCase {
    
    private var timelineViewController : TimelineViewController!
    private var mockMetricsService : MockMetricsService!
    private var mockEditStateService : MockEditStateService!
    private var mockPersistencyService : MockPersistencyService!
    private var viewModel : TimelineViewModel!
    
    override func setUp()
    {
        super.setUp()
        
        self.mockMetricsService = MockMetricsService()
        self.mockEditStateService = MockEditStateService()
        self.mockPersistencyService = MockPersistencyService()
        
        self.viewModel = TimelineViewModel(date: Date(),
                                           metricsService: self.mockMetricsService,
                                           persistencyService: self.mockPersistencyService)
        self.timelineViewController = TimelineViewController(date: Date(),
                                                             metricsService: self.mockMetricsService,
                                                             editStateService: self.mockEditStateService,
                                                             persistencyService: self.mockPersistencyService)
    }
    
    override func tearDown()
    {
        super.tearDown()
        
        self.timelineViewController.viewWillDisappear(false)
        self.timelineViewController = nil
    }
    
    func testScrollingIsDisabledWhenEnteringEditMode()
    {
        self.mockEditStateService.notifyEditingBegan(point: CGPoint(), timeSlot: TimeSlot());
        
        let scrollView = self.timelineViewController.tableView!
        
        expect(scrollView.isScrollEnabled).to(beFalse())
    }
    
    func testScrollingIsEnabledWhenExitingEditMode()
    {
        self.mockEditStateService.notifyEditingBegan(point: CGPoint(), timeSlot: TimeSlot());
        self.mockEditStateService.notifyEditingEnded();
        
        let scrollView = self.timelineViewController.tableView!
        
        expect(scrollView.isScrollEnabled).to(beTrue())
    }
    
    func testUIRefreshesAsTimePasses()
    {
        let indexPath = IndexPath(row: self.viewModel.timeSlots.count - 1, section: 0)
        let cell = self.timelineViewController.tableView(self.timelineViewController.tableView, cellForRowAt: indexPath) as! TimelineCell
        let beforeElapsedTimeText = cell.elapsedTime.text
        
        //60 sec. are needed to pass in order to see changes in the UI
        RunLoop.current.run(until: Date().addingTimeInterval(60))
        
        expect(cell.elapsedTime.text).toNot(equal(beforeElapsedTimeText))
    }
    
}
