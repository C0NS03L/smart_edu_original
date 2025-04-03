document.addEventListener('DOMContentLoaded', () => {
  // Pie Chart
  const pieCtx = document.getElementById('attendancePieChart').getContext('2d')
  const totalStudents = parseInt(document.getElementById('attendancePieChart').dataset.totalStudents, 10)
  const attendingStudents = parseInt(document.getElementById('attendancePieChart').dataset.attendingStudents, 10)

  new Chart(pieCtx, {
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

  // Bar Chart
  const barCtx = document.getElementById('attendanceBarChart').getContext('2d')
  const attendanceData = JSON.parse(barCanvas.dataset.attendanceData)

  new Chart(barCtx, {
    type: 'bar',
    data: {
      labels: attendanceData.dates,
      datasets: [
        {
          label: 'Daily Attendance',
          data: attendanceData.counts,
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
})
