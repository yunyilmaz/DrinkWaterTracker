import Testing
@testable import test

struct WaterViewModelTests {
    
    @Test func testAddWaterIntake() async throws {
        // Setup
        let viewModel = WaterViewModel()
        viewModel.resetData()
        let initialCount = viewModel.waterIntakes.count
        let testAmount = 250.0
        
        // Act
        viewModel.addWaterIntake(amount: testAmount)
        
        // Assert
        #expect(viewModel.waterIntakes.count == initialCount + 1)
        #expect(viewModel.waterIntakes.last?.amount == testAmount)
        #expect(viewModel.todayTotal == testAmount)
    }
    
    @Test func testUpdateDailyGoal() async throws {
        // Setup
        let viewModel = WaterViewModel()
        let newTarget = 3000.0
        
        // Act
        viewModel.updateDailyGoal(target: newTarget)
        
        // Assert
        #expect(viewModel.dailyGoal.target == newTarget)
    }
    
    @Test func testRemoveWaterIntake() async throws {
        // Setup
        let viewModel = WaterViewModel()
        viewModel.resetData()
        viewModel.addWaterIntake(amount: 100)
        viewModel.addWaterIntake(amount: 200)
        let initialCount = viewModel.waterIntakes.count
        
        // Act
        viewModel.removeWaterIntake(at: IndexSet(integer: 0))
        
        // Assert
        #expect(viewModel.waterIntakes.count == initialCount - 1)
        #expect(viewModel.todayTotal == 200)
    }
    
    @Test func testGetDailyProgress() async throws {
        // Setup
        let viewModel = WaterViewModel()
        viewModel.resetData()
        viewModel.updateDailyGoal(target: 2000)
        
        // Act & Assert
        #expect(viewModel.getDailyProgress() == 0)
        
        viewModel.addWaterIntake(amount: 500)
        #expect(viewModel.getDailyProgress() == 0.25)
        
        viewModel.addWaterIntake(amount: 1500)
        #expect(viewModel.getDailyProgress() == 1.0)
        
        viewModel.addWaterIntake(amount: 1000)
        #expect(viewModel.getDailyProgress() == 1.0) // Should cap at 100%
    }
    
    @Test func testCalculateTodayTotal() async throws {
        // Setup
        let viewModel = WaterViewModel()
        viewModel.resetData()
        
        // Act
        viewModel.addWaterIntake(amount: 300)
        viewModel.addWaterIntake(amount: 500)
        
        // Assert
        #expect(viewModel.todayTotal == 800)
    }
}
