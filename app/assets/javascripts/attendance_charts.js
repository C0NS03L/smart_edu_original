// Multiple event listeners to ensure charts are initialized properly
function initializeCharts() {
  console.log('Initializing charts...')

  // Pie Chart initialization (unchanged)
  try {
    const pieChartElement = document.getElementById('attendancePieChart')
    if (!pieChartElement) {
      console.log('Pie chart element not found, skipping initialization')
      return
    }

    const pieCtx = pieChartElement.getContext('2d')
    const totalStudents = parseInt(pieChartElement.dataset.totalStudents, 10)
    const attendingStudents = parseInt(pieChartElement.dataset.attendingStudents, 10)

    // Check if chart instance already exists and destroy it
    if (window.pieChartInstance) {
      window.pieChartInstance.destroy()
    }

    window.pieChartInstance = new Chart(pieCtx, {
      type: 'pie',
      data: {
        labels: ['Attending Students', 'Absent Students'],
        datasets: [
          {
            data: [attendingStudents, totalStudents - attendingStudents],
            backgroundColor: ['#4CAF50', '#F44336']
          }
        ]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: { position: 'top' },
          tooltip: {
            callbacks: {
              label: function (tooltipItem) {
                const label = tooltipItem.label || ''
                const value = tooltipItem.raw || 0
                return `${label}: ${value}`
              }
            }
          }
        }
      }
    })
    console.log('Pie chart initialized successfully')
  } catch (error) {
    console.error('Error initializing Pie Chart:', error)
  }

  try {
    const barChartElement = document.getElementById('attendanceBarChart')
    if (!barChartElement) {
      console.log('Bar chart element not found, skipping initialization')
      return
    }

    const barCtx = barChartElement.getContext('2d')

    // Get raw data and log it for debugging
    const rawData = barChartElement.dataset.attendanceData
    console.log('Raw attendance data:', rawData)

    let attendanceData
    try {
      attendanceData = JSON.parse(rawData)
      console.log('Parsed attendance data:', attendanceData)
    } catch (parseError) {
      console.error('Failed to parse attendance data JSON:', parseError)
      return
    }

    // Check data validity
    if (!attendanceData) {
      console.error('No attendance data available for the bar chart.')
      return
    }

    // Initialize arrays for chart data
    let labels = []
    let values = []

    // SPECIFIC CASE for your data format: object with 'dates' and 'counts' arrays
    if (
      attendanceData.dates &&
      attendanceData.counts &&
      Array.isArray(attendanceData.dates) &&
      Array.isArray(attendanceData.counts)
    ) {
      labels = attendanceData.dates
      values = attendanceData.counts
      console.log('Using dates/counts arrays format:', { labels, values })
    }
    // Case 1: If attendanceData is an object with keys for dates and values for counts
    else if (typeof attendanceData === 'object' && !Array.isArray(attendanceData)) {
      labels = Object.keys(attendanceData)
      values = Object.values(attendanceData)
      console.log('Using object format data:', { labels, values })
    }
    // Case 2: If attendanceData is an array of objects with date and count properties
    else if (
      Array.isArray(attendanceData) &&
      attendanceData.length > 0 &&
      typeof attendanceData[0] === 'object' &&
      'date' in attendanceData[0] &&
      'count' in attendanceData[0]
    ) {
      labels = attendanceData.map((record) => record.date)
      values = attendanceData.map((record) => record.count)
      console.log('Using array of objects format data:', { labels, values })
    }
    // Case 3: If attendanceData is an array with just numbers
    else if (Array.isArray(attendanceData) && attendanceData.length > 0 && typeof attendanceData[0] === 'number') {
      labels = Array.from({ length: attendanceData.length }, (_, i) => `Day ${i + 1}`)
      values = attendanceData
      console.log('Using array of numbers format data:', { labels, values })
    }
    // Case 4: None of the above - log error and try to provide helpful debugging
    else {
      console.error('Attendance data is in an unexpected format:', attendanceData)
      return
    }

    // Check if we have data to display
    if (labels.length === 0 || values.length === 0) {
      console.error('No usable data found for the bar chart after parsing.')
      return
    }

    // Check if chart instance already exists and destroy it
    if (window.barChartInstance) {
      window.barChartInstance.destroy()
    }

    window.barChartInstance = new Chart(barCtx, {
      type: 'bar',
      data: {
        labels: labels,
        datasets: [
          {
            label: 'Daily Attendance',
            data: values,
            backgroundColor: '#4CAF50'
          }
        ]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: { display: false },
          tooltip: {
            callbacks: {
              label: function (tooltipItem) {
                return `Attendance: ${tooltipItem.raw}`
              }
            }
          }
        },
        scales: {
          x: { title: { display: true, text: 'Days' } },
          y: { title: { display: true, text: 'Students' }, beginAtZero: true }
        }
      }
    })
    console.log('Bar chart initialized successfully')
  } catch (error) {
    console.error('Error initializing Bar Chart:', error)
  }
}

// Register multiple event listeners to ensure charts are initialized
document.addEventListener('DOMContentLoaded', initializeCharts)
document.addEventListener('turbolinks:load', initializeCharts)
document.addEventListener('page:load', initializeCharts) // For older Turbolinks
document.addEventListener('ready', initializeCharts)

// If all else fails, try to initialize after a short delay
window.addEventListener('load', function () {
  setTimeout(initializeCharts, 500)
})

// Additionally, check if document is already loaded and initialize immediately
if (document.readyState === 'complete' || document.readyState === 'interactive') {
  console.log('Document already ready, initializing now')
  setTimeout(initializeCharts, 100)
}
